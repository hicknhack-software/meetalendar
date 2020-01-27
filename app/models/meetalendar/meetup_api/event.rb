module Meetalendar
  module MeetupApi
    class Event
      attr_reader :json

      # see https://www.meetup.com/de-DE/meetup_api/docs/:urlname/events/:id/
      def initialize(json)
        @json = json
      end

      def id
        json['id'].to_s
      end

      def group_id
        json.dig('group', 'id')&.to_i
      end

      def group_name
        json.dig('group', 'name')&.to_s
      end

      def group_urlname
        json.dig('group', 'urlname')&.to_s
      end

      def name
        json['name'].to_s
      end

      def link
        json['link'].to_s
      end

      def link?
        json.key? 'link'
      end

      def description
        json['description'].to_s
      end

      def venue?
        json.key? 'venue'
      end

      def city
        json.dig('venue', 'city')&.to_s || ''
      end

      def yes_rsvp_count
        json['yes_rsvp_count'].to_i
      end

      def utc_offset
        json['utc_offset'].to_i / 1000
      end

      def start_time
        t = Time.at(Rational(json['time'].to_i) / 1000)
        Time.new(t.year, t.mon, t.mday, t.hour, t.min, t.usec, utc_offset)
      end

      def end_time
        t = Time.at(Rational(json['time'].to_i + json['duration'].to_i) / 1000)
        Time.new(t.year, t.mon, t.mday, t.hour, t.min, t.usec, utc_offset)
      end

      def self.gcal_id?(id)
        id.start_with?('meetalendar')
      end

      def series?
        json.key? 'series'
      end

      def gcal_id
        "meetalendar#{Digest::MD5.hexdigest(id)}"
      end

      def gcal_summary
        if group_name.downcase.split.any? { |w| w.length > 4 and name.downcase.include? w }
          name
        else
          "#{name} [#{group_name}]"
        end
      end

      def gcal_location
        if venue?
          name_address = if json['venue']['name'] != json['venue']['address_1']
                           "#{json['venue']['name']}, #{json['venue']['address_1']}"
                         else
                           "#{json['venue']['address_1']}"
                         end
          "#{name_address}, #{json['venue']['city']}, #{json['venue']['localized_country_name']}"
        else
          ""
        end
      end

      def gcal_description
        "#{description.gsub(/<p>/, '<div>').gsub!(/<\/p>/, '</div>')}#{"<div>Link: #{link}</div>" if link?}"
      end

      def gcal_start
        Google::Apis::CalendarV3::EventDateTime.new(
            date_time: DateTime.parse(start_time.to_s).to_s,
            time_zone: Time.zone.name
        )
      end

      def gcal_end
        Google::Apis::CalendarV3::EventDateTime.new(
            date_time: DateTime.parse(end_time.to_s).to_s,
            time_zone: Time.zone.name
        )
      end

      GCAL_SOURCE_TITLE = 'Meetalendar'
      def gcal_source
        Google::Apis::CalendarV3::Event::Source.new(
            title: GCAL_SOURCE_TITLE,
            url: link
        )
      end

      def gcal_event
        # see https://developers.google.com/calendar/v3/reference/events
        Google::Apis::CalendarV3::Event.new(
          id: gcal_id,
          summary: gcal_summary,
          location: gcal_location,
          description: gcal_description,
          start: gcal_start,
          end: gcal_end,
          source: gcal_source
      )
      end

      def equal_with_gcal_event?(gcal_event)
        gcal_event.summary == self.gcal_event.summary &&
        gcal_event.location == self.gcal_event.location &&
        gcal_event.description == self.gcal_event.description &&
        gcal_event.start.date_time.to_s == self.gcal_event.start.date_time.to_s &&
        gcal_event.start.time_zone == self.gcal_event.start.time_zone &&
        gcal_event.end.date_time.to_s == self.gcal_event.end.date_time.to_s &&
        gcal_event.end.time_zone == self.gcal_event.end.time_zone &&
        gcal_event.source.title == self.gcal_event.source.title &&
        gcal_event.source.url == self.gcal_event.source.url
      end
    end
  end
end
