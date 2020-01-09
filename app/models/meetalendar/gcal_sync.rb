require 'active_resource'
require "google/apis/calendar_v3"

module Meetalendar
  module GcalSync

    def self.update_events(meetup_events, calendar_id, time_now, time_limit)
      calendar_service = self.calendar_service
      time_min = DateTime.parse(time_now.to_s).to_s
      time_max = DateTime.parse(time_limit.to_s).to_s

      begin
        gcal_events = calendar_service.list_events(calendar_id, time_min: time_min, time_max: time_max, show_deleted: true).items
      rescue => exception
        Rails.logger.error "An exception occurred while loading current events from the google calendar. Exception: #{exception.message}"
        raise ::ActiveResource::ClientError, "Could not load current events from the google calendar."
      end

      meetup_ids = meetup_events.map(&:gcal_id)
      gcal_events.each do |gcal_event|
        calendar_service.delete_event(calendar_id, gcal_event.id) if gcal_event.status != 'cancelled' and not meetup_ids.include?(gcal_event.id)
      rescue => exception
        Rails.logger.error "An exception occurred while deleting unsubscribed events from the google calendar. Exception: #{exception.message}"
        raise ::ActiveResource::ClientError, "Could not delete unsubscribed events from the google calendar."
      end

      gcal_ids = gcal_events.map(&:id)
      meetup_events.each do |event|
        if gcal_ids.include? event.gcal_id
          calendar_service.update_event(calendar_id, event.gcal_id, event.gcal_event)
        else
          calendar_service.insert_event(calendar_id, event.gcal_event)
        end
      rescue => exception
        Rails.logger.error "An exception occurred while updating or inserting events into the google calendar. Exception: #{exception.message}"
        raise ::ActiveResource::ClientError, "Could not update or insert event into the google calendar."
      end
    end

    private

    def self.calendar_service
      calendar_service = Google::Apis::CalendarV3::CalendarService.new
      calendar_service.client_options.application_name = GcalApi::Auth::GOOGLE_CALENDAR_AUTH_APPLICATION_NAME
      calendar_service.authorization = GcalApi::Auth.authorize
      calendar_service
    end

  end
end
