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

      def start_time
        Time.at(Rational(json['time'].to_i) / 1000, Rational(json['utc_offset'].to_i) / (24 * 60 * 601000))
      end

      def end_time
        Time.at(Rational(json['time'].to_i + json['duration'].to_i) / 1000, Rational(json['utc_offset'].to_i) / (24 * 60 * 601000))
      end

      def self.gcal_id?(id)
        id.start_with?('meetalendar')
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
        {
            date_time: DateTime.parse(start_time.to_s).to_s,
            time_zone: Time.zone.name
        }
      end

      def gcal_end
        {
            date_time: DateTime.parse(end_time.to_s).to_s,
            time_zone: Time.zone.name
        }
      end

      GCAL_SOURCE_TITLE = 'Meetalendar'
      def gcal_source
        {
            title: GCAL_SOURCE_TITLE,
            url: link
        }
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
    end
  end
end
