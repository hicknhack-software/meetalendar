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
      client = HTTPClient.new
      result = client.get(api_uri(path), query: args.merge('access_token': Oauth.tokens.access_token))
      if result&.status == Rack::Utils::status_code(:unauthorized)
        result = client.get(api_uri(path), query: args.merge('access_token': Oauth.refresh.access_token))
      end
      JSON.parse(result.success_content || '{}')
    end

    def self.api_uri(path)
      "https://api.meetup.com#{path}"
    end

  end
end
