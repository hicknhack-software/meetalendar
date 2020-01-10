require "google/apis/calendar_v3"

module Meetalendar
  module GcalSync

    def self.update_events(meetup_events, calendar_id, time_now, time_limit)
      time_min = DateTime.parse(time_now.to_s).to_s
      time_max = DateTime.parse(time_limit.to_s).to_s

      gcal_events = self.calendar_service.list_events(calendar_id, time_min: time_min, time_max: time_max, show_deleted: true).items

      meetup_ids = meetup_events.map(&:gcal_id)
      gcal_events.each do |gcal_event|
        self.calendar_service.delete_event(calendar_id, gcal_event.id) if gcal_event.status != 'cancelled' and not meetup_ids.include?(gcal_event.id)
      end

      gcal_ids = gcal_events.map(&:id)
      meetup_events.each do |event|
        if gcal_ids.include? event.gcal_id
          self.calendar_service.update_event(calendar_id, event.gcal_id, event.gcal_event)
        else
          self.calendar_service.insert_event(calendar_id, event.gcal_event)
        end
      end
    end

    private

    def self.calendar_service
      Google::Apis::CalendarV3::CalendarService.new.tap do |service|
        service.client_options.application_name = GcalApi::Auth::GOOGLE_CALENDAR_AUTH_APPLICATION_NAME
        service.authorization = GcalApi::Auth.authorize
      end
    end

  end
end
