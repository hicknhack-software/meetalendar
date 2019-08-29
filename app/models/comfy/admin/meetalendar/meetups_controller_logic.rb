require 'rubygems'
require 'active_resource'

require 'multi_json'
require_relative "../../../google/auth/store/db_token_store"

module Comfy::Admin::Meetalendar::MeetupsControllerLogic
  class Comfy::Admin::Meetalendar::MeetupsControllerLogic::SearchResult
    attr_reader :groups_id_name
    attr_reader :found_upcoming_grouped_events
    attr_reader :found_last_grouped_events
    attr_reader :meetup_groups

    def initialize(groups_id_name, found_upcoming_grouped_events, found_last_grouped_events, meetup_groups)
      @groups_id_name = groups_id_name
      @found_upcoming_grouped_events = found_upcoming_grouped_events
      @found_last_grouped_events = found_last_grouped_events
      @meetup_groups = meetup_groups
    end
  end

  def self.authorize_meetup(request, callback_path)
    meetup_credentials = ::MEETALENDAR_CREDENTIALS_MEETUP

    redirect_url = "https://secure.meetup.com/oauth2/authorize" +
      "?client_id=#{meetup_credentials["client_id"]}" +
      "&response_type=code" +
      "&redirect_uri=#{request.protocol}#{request.host_with_port}#{callback_path.to_s}"
  end

  def self.callback(code, request, callback_path)
    meetup_credentials = ::MEETALENDAR_CREDENTIALS_MEETUP

    request_uri = "https://secure.meetup.com/oauth2/access"
    request_query_hash = {"client_id": meetup_credentials["client_id"], "client_secret": meetup_credentials["client_secret"], "grant_type": "authorization_code", "redirect_uri": "#{request.protocol}#{request.host_with_port}#{callback_path.to_s}", "code": "#{code}"}

    client = HTTPClient.new
    begin
      response = JSON.parse(client.post_content(request_uri, request_query_hash))
    rescue => ex
      Rails.logger.error "Failed to authorize Meetup API. Exception in callback: #{ex.message}"
      raise ::ActiveResource::ClientError, "Failed to authorize Meetup API."
    end

    if !response.nil?
      token_store = Google::Auth::Stores::DbTokenStore.new
      token_store.store("meetup", {"auth_id": "meetup", "client_id": meetup_credentials["client_id"], "access_token": response["access_token"], "refresh_token": response["refresh_token"], "scope": "", "expiration_time_millis": response["expires_in"] * 1000}.to_json.to_s)
    end
  end

  def self.search_result(parameters, time_now)
    group_params = JSON.parse(parameters.nil? ? {} : parameters)

    request_result = Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.get_path_authorized("/find/groups", group_params.merge({"fields" => "last_event"}))
    groups = request_result.nil? ? {} : request_result

    groups_id_name = groups.map{|g| {id: g["id"].to_i, name: g["name"].to_s, link: g["link"].to_s} }
    group_ids = groups.map{|g| g["id"]}
    request_result = Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.get_path_authorized("/find/upcoming_events", {"page": 200})
    upcoming_events = request_result.nil? ? [] : request_result["events"]

    upcoming_events_of_groups = upcoming_events.select{|e| !e["group"].nil? && group_ids.include?(e["group"]["id"])}

    grouped_upcoming_events = upcoming_events_of_groups.group_by{|e| e["group"]["id"]}
    limited_upcoming_events = Hash[grouped_upcoming_events.map{|k, v| [k, v.select{|e| Time.at(Rational(e["time"], 1000)) > time_now}.sort_by{|e| e["time"]}.take(2)]}].select{|k, v| v.any?}

    found_upcoming_grouped_events = limited_upcoming_events

    last_events = Hash[groups.group_by{|g| g["id"]}.map{|k, v| [k, v.map{|g| g["last_event"]}]}].select{|k, v| v.any?}
    found_last_grouped_events = last_events

    meetup_groups = groups.map{|g| Comfy::Admin::Meetalendar::MeetupGroup.new({"group_id": g["id"], "name": g["name"], "approved_cities": "", "group_link": g["link"]})}

    search_result = Comfy::Admin::Meetalendar::MeetupsControllerLogic::SearchResult.new(groups_id_name, found_upcoming_grouped_events, found_last_grouped_events, meetup_groups)
  end

end
