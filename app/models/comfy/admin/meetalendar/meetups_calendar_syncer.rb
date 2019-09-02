require 'rubygems'
require 'active_resource'

require "date"
require_relative "../../../google/auth/store/db_token_store"
require "google/apis/calendar_v3"
require "googleauth"

require_relative "../../../../controllers/comfy/admin/meetalendar/meetups_controller"

module Comfy::Admin::Meetalendar::MeetupsCalendarSyncer
  GOOGLE_CALENDAR_AUTH_OOB_URI ||= "urn:ietf:wg:oauth:2.0:oob".freeze
  GOOGLE_CALENDAR_AUTH_APPLICATION_NAME ||= "Google Calendar API Ruby MeetupSync".freeze
  GOOGLE_CALENDAR_AUTH_SCOPE ||= Google::Apis::CalendarV3::AUTH_CALENDAR_EVENTS.freeze

  def self.prepare_authorizer
    client_id = ::MEETALENDAR_CREDENTIALS_GOOGLE_CALENDAR_CLIENT_ID
    token_store = Google::Auth::Stores::DbTokenStore.new
    authorizer = Google::Auth::UserAuthorizer.new client_id, GOOGLE_CALENDAR_AUTH_SCOPE, token_store
  end

  def self.get_authorization_url
    self.prepare_authorizer.get_authorization_url base_url: GOOGLE_CALENDAR_AUTH_OOB_URI
  end

  def self.authorize_and_remember(key_code)
    authorizer = self.prepare_authorizer
    user_id = "default"

    begin
      authorizer.get_and_store_credentials_from_code(user_id: user_id, code: key_code, base_url: GOOGLE_CALENDAR_AUTH_OOB_URI)
    rescue => exception
      Rails.logger.error "Authorization of google calendar api failed with exception: #{exception.message}"
      raise ::ActiveResource::UnauthorizedAccess, "Authorization at google calendar failed."
    end
  end

  def self.authorize
    authorizer = self.prepare_authorizer
    user_id = "default"
    credentials = authorizer.get_credentials user_id

    if credentials.nil?
      Rails.logger.error "Authorization failed as no google calendar api credentials are present."
      raise ::ActiveResource::UnauthorizedAccess, "Please go to: <host>/admin/meetups in the admin interface of the website and renew the authorization of the calendar api."
    end
    credentials
  end

  def self.add_to_key(current_key_data, to_add_data)
    return_key_data = current_key_data.nil? ? [] : current_key_data.class == [].class ? current_key_data : [].push(current_key_data)
    return_key_data.push(to_add_data)
    return_key_data
  end

  def self.get_path_authorized(path, args = {})
    return_hash = {}
    client = HTTPClient.new
    token_store = Google::Auth::Stores::DbTokenStore.new
    loaded_token = token_store.load("meetup")
    if loaded_token.nil?
      Rails.logger.error "Authorization failed as no currently authorized meetup api token was present."
      raise ::ActiveResource::UnauthorizedAccess, "To access this path you need to have authenticated the Meetup API successfully."
      parsed_path = {}.to_s
    else
      # try
      current_tokens = JSON.parse(loaded_token)
      request_uri = "https://api.meetup.com" + path.to_s
      request_query_args = args.merge({"access_token" => (current_tokens["access_token"])})
      result = client.request("GET", request_uri, request_query_args)

      if result.nil? || result.status == Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized]
        meetup_credentials = ::MEETALENDAR_CREDENTIALS_MEETUP
        request_uri = "https://secure.meetup.com/oauth2/access"
        request_query_args = {"client_id": meetup_credentials["client_id"], "client_secret": meetup_credentials["client_secret"], "grant_type": "refresh_token", "refresh_token": "#{current_tokens["refresh_token"]}"}
        post_return = client.post_content(request_uri, request_query_args)

        if post_return.nil? || post_return.status == Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized]
          Rails.logger.error "Authorization with current token failed and token could not be refreshed. Was authorization to meetup api revoked?"
          raise ::ActiveResource::UnauthorizedAccess, "To access this path you need to have authenticated the Meetup API successfully."
        else
          response = JSON.parse(post_return.to_s)
          token_store.store("meetup", {"auth_id": "meetup", "client_id": meetup_credentials["client_id"], "access_token": response["access_token"], "refresh_token": response["refresh_token"], "scope": "", "expiration_time_millis": response["expires_in"] * 1000}.to_json.to_s)

          # retry with refreshed token
          current_tokens = JSON.parse(loaded_token)
          request_uri = "https://api.meetup.com" + path.to_s
          request_query_args = args.merge({"access_token" => (current_tokens["access_token"])})
          result = client.request("GET", request_uri, request_query_args)
  
          if result.nil? || result.status != Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
            # still no success
            Rails.logger.error "Authorization with current token failed, token was refreshed but authorization still fails. Was authorization to meetup api revoked?"
            raise ::ActiveResource::UnauthorizedAccess, "To access this path you need to have authenticated the Meetup API successfully."
          else
            parsed_path = JSON.parse(result&.body.nil? ? {}.to_s : result.body.to_s)
          end
        end

      else
        parsed_path = JSON.parse(result&.body.nil? ? {}.to_s : result.body.to_s)
      end
    end

    parsed_path
  end

  def self.gather_selected_events(time_now)
    @meetups = MeetupGroup.all
    group_ids = @meetups.map{ |meetup| meetup.group_id }
    group_ids_approved_cities = @meetups.map{|meetup| ["#{meetup.group_id}", meetup.approved_cities.downcase.split(%r{,\s*})]}.to_h

    request_result = Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.get_path_authorized("/find/upcoming_events", {"page": 200})

    upcoming_events = request_result.nil? || request_result.empty? ? [] : request_result.dig("events")
    selected_groups_upcoming_events = upcoming_events.select{|event| group_ids.include?(event.dig("group", "id"))}

    upcoming_events_of_groups = selected_groups_upcoming_events.select do |event|
      selected_group_has_approved_cities = !group_ids_approved_cities.dig("#{event.dig("group", "id")}").empty?

      event_has_group = !event.dig("group").nil?
      events_group_id_is_in_selected_group_ids = group_ids.include?(event.dig("group", "id"))

      event_has_no_venue = event.dig("venue").nil?
      event_has_venue = !event.dig("venue").nil?

      event_venue_in_approved_cities = !selected_group_has_approved_cities ? true : group_ids_approved_cities.dig("#{event.dig("group", "id")}").include?(event.dig('venue', 'city').to_s.downcase)

      !selected_group_has_approved_cities ||
        (selected_group_has_approved_cities &&
        event_has_group && events_group_id_is_in_selected_group_ids &&
        (event_has_no_venue || (event_has_venue && event_venue_in_approved_cities)))
    end

    grouped_upcoming_events = upcoming_events_of_groups.group_by{|event| event.dig("group", "id")}
    limited_upcoming_events = grouped_upcoming_events.map{|k, v| v.select{|event| Time.at(Rational(event.dig("time").to_i, 1000)) > time_now}}.first
  end

  def self.sync_meetups_to_calendar(listed_upcoming_events, calendar_id, time_now, time_in_future)
    calendar_service = Google::Apis::CalendarV3::CalendarService.new
    calendar_service.client_options.application_name = GOOGLE_CALENDAR_AUTH_APPLICATION_NAME
    calendar_service.authorization = authorize

    begin
      all_future_google_calendar_events = calendar_service.list_events(calendar_id, {time_max: DateTime.parse(time_in_future.to_s).to_s, time_min: DateTime.parse(time_now.to_s).to_s})
    rescue => exception
        Rails.logger.error "An exception occurred while loading current events from the google calendar. Exception: #{exception.message}"
        raise ::ActiveResource::ClientError, "Could not load current events from the google calendar."
    end

    to_keep_event_gcal_ids = listed_upcoming_events.map{|mu_event| Digest::MD5.hexdigest(mu_event.dig('id').to_s)}
    to_delete_event_ids = all_future_google_calendar_events.items.map{|gcal_event| gcal_event.id}.select{|gcal_event_id| !to_keep_event_gcal_ids.include?(gcal_event_id)}

    to_delete_event_ids.each{ |event_id|
      begin
        calendar_service.delete_event(calendar_id, event_id)
      rescue => exception
          Rails.logger.error "An exception occurred while deleting unsubscribed events from the google calendar. Exception: #{exception.message}"
          raise ::ActiveResource::ClientError, "Could not delete unsubscribed events from the google calendar."
      end
    }

    listed_upcoming_events.each{ |event|
      if event.key?('venue')
        venue_name_adress = event['venue']['name'] != event['venue']['address_1'] ? "#{event['venue']['name']}, #{event['venue']['address_1']}" : "#{event['venue']['address_1']}"
        location = "#{venue_name_adress}, #{event['venue']['city']}, #{event['venue']['localized_country_name']}"
      else
        if event.key?('link')
          location = event['link'].to_s
        else
          location = ""
        end
      end

      description = event['description'].to_s + (defined?(event['link']) ? "\nLink: " + event['link'].to_s : "")
      start_date_time = DateTime.parse(Time.at(Rational(event['time'].to_i, 1000)).to_s).to_s
      end_date_time = DateTime.parse(Time.at(Rational(event['time'].to_i + event['duration'].to_i, 1000)).to_s).to_s

      new_event_hash = {
        id: Digest::MD5.hexdigest(event['id'].to_s),
        summary: event['name'].to_s,
        location: location,
        description: description,
        start: {
          date_time: start_date_time,
          time_zone: Time.zone.name
        },
        end: {
          date_time: end_date_time,
          time_zone: Time.zone.name
        },
      }

      new_event = Google::Apis::CalendarV3::Event.new(new_event_hash)
      begin
        calendar_service.update_event(calendar_id, new_event.id, new_event)
      rescue # TODO(Schau): If possible, figure out the exact exceptions to minimize "braodness of healing"
        begin
          calendar_service.insert_event(calendar_id, new_event)
        rescue => exception
            Rails.logger.error "An exception occurred while updating or inserting events into the google calendar. Exception: #{exception.message}"
            raise ::ActiveResource::ClientError, "Could not update or insert event into the google calendar."
        end
      end
    }
  end
end
