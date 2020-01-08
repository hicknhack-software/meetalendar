module Meetalendar
  module MeetupApi

    class Group
      attr_reader :json
      attr_accessor :last_event
      attr_accessor :upcoming_events

      def initialize(json)
        @json = json
        @last_event = Event.new(json['last_event']) if json.key?('last_event')
        @upcoming_events = []
      end

      def id
        json['id'].to_i
      end

      def name
        json['name'].to_s
      end

      def link
        json['link'].to_s
      end

      def meetup_link
        link
      end

      def present?
        false
      end
    end

  end
end
