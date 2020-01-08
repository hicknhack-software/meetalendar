require 'httpclient'
require 'multi_json'
require 'active_resource'

module Meetalendar
  module MeetupApi

    def self.get(path, args = {})
      client = HTTPClient.new
      tokens = self.tokens

      request_uri = "https://api.meetup.com" + path.to_s
      request_query_args = args.merge('access_token': tokens.access_token)
      result = client.request("GET", request_uri, request_query_args)
      return JSON.parse(result.body || '{}') if result&.status == Rack::Utils::status_code(:ok)

      if result&.status == Rack::Utils::status_code(:unauthorized)
        tokens = Oauth.refresh

        # retry with refreshed token
        request_query_args = args.merge('access_token': tokens.access_token)
        result = client.request("GET", request_uri, request_query_args)
        return JSON.parse(result.body || '{}') if result&.status == Rack::Utils::status_code(:ok)

        # still no success
        Rails.logger.error "Authorization with current token failed, token was refreshed but authorization still fails. Was authorization to meetup api revoked?"
        raise ::ActiveResource::UnauthorizedAccess, "To access this path you need to have authenticated the Meetup API successfully."
      end
    end

    def self.find_groups(args = {})
      groups_json = self.get "/find/groups", args

      (groups_json || []).map do |group_json|
        Group.new(group_json)
      end
    end

    def self.find_upcoming_events(args = {})
      events_json = self.get "/find/upcoming_events", args

      (events_json&.dig('events') || []).map do |event_json|
        Event.new(event_json)
      end
    end

    def self.search_groups(request_params, time_now = nil)
      time_now ||= Time.now

      groups = self.find_groups(request_params.merge({'fields': 'last_event'}))
      upcoming_events = self.find_upcoming_events({"page": 200})

      group_ids = groups.map(&:id)
      filtered_events = upcoming_events.select do |e|
        e.start_time > time_now and group_ids.include?(e.group_id)
      end

      grouped_events = filtered_events.group_by(&:group_id)
      grouped_events.default = []

      groups.each do |group|
        group.upcoming_events = grouped_events[group.id].sort_by(&:start_time).take(2)
      end
    end

    private

    def self.tokens
      Oauth.tokens || begin
        Rails.logger.error "Authorization failed as no currently authorized meetup api token was present."
        raise ::ActiveResource::UnauthorizedAccess, "To access this path you need to have authenticated the Meetup API successfully."
      end
    end
  end
end
