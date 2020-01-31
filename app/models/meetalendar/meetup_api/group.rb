module Meetalendar
  module MeetupApi

    class Group
      attr_reader :json
      attr_accessor :last_event
      attr_accessor :past_event_count
      attr_accessor :next_event
      attr_accessor :upcoming_event_count
      attr_accessor :proposed_event_count
      attr_accessor :draft_event_count

      def initialize(json)
        @json = json
        @last_event = Event.new(json['last_event']) if json.key?('last_event')
        @past_event_count = json['past_event_count'].to_i if json.key?('past_event_count')
        @next_event = Event.new(json['next_event']) if json.key?('next_event')
        @upcoming_event_count = json['upcoming_event_count'].to_i if json.key?('upcoming_event_count')
        @proposed_event_count = json['proposed_event_count'].to_i if json.key?('proposed_event_count')
        @draft_event_count = json['draft_event_count'].to_i if json.key?('draft_event_count')
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
