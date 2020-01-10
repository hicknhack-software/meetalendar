require 'httpclient'
require 'multi_json'

module Meetalendar
  module MeetupApi

    def self.find_groups(args = {})
      (get("/find/groups", args) || []).map do |group_json|
        Group.new group_json
      end
    end

    def self.find_upcoming_events(args = {})
      (get("/find/upcoming_events", args)&.dig('events') || []).map do |event_json|
        Event.new event_json
      end
    end

    def self.search_groups(request_params, time_now = nil)
      time_now ||= Time.now

      groups = find_groups(request_params.merge({'fields': 'last_event'}))
      upcoming_events = find_upcoming_events({"page": 200})

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

    def self.get(path, args = {})
      get_with_auth path, args, Oauth.tokens
    rescue HTTPClient::BadResponseError => e
      raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
      get_with_auth path, args, Oauth.refresh # retry with refreshed tokens
    end

    def self.get_with_auth(path, args, auth)
      JSON.parse HTTPClient.get_content api_uri(path), query: args.merge('access_token': auth.access_token)
    end

    def self.api_uri(path)
      "https://api.meetup.com#{path}"
    end

  end
end
