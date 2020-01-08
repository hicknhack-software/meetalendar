module Meetalendar
  module MeetupApi
    class Event
      attr_reader :json

      def initialize(json)
        @json = json
      end

      def id
        json['id'].to_i
      end

      def group_id
        json&.dig('group', 'id')&.to_i
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

      def gcal_id
        Digest::MD5.hexdigest(id.to_s)
      end

      def gcal_location
        if venue?
          name_address = if json['venue']['name'] != json['venue']['address_1']
                           "#{json['venue']['name']}, #{json['venue']['address_1']}"
                         else
                           "#{json['venue']['address_1']}"
                         end
          "#{name_address}, #{json['venue']['city']}, #{json['venue']['localized_country_name']}"
        elsif link?
          link
        else
          ""
        end
      end

      def gcal_description
        "#{description}#{"\nLink: #{link}" if link?}"
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

      def gcal_event
        Google::Apis::CalendarV3::Event.new(
            id: gcal_id,
            summary: name,
            location: gcal_location,
            description: gcal_description,
            start: gcal_start,
            end: gcal_end
        )
      end
    end
  end
end
