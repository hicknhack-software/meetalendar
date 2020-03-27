require "google/apis/calendar_v3"

module Meetalendar
  module GcalSync

    def self.update_events(meetup_events, calendar_id, time_now, time_limit)
      meetalendar_instance = Meetalendar::Setting.instance

      gcal_events = self.calendar_service.list_events(calendar_id,
                                                      time_min: time_now.to_datetime,
                                                      time_max: time_limit.to_datetime,
                                                      show_deleted: true)
                        .items.select do |gcal_event|
        gcal_event.start.date_time&.between?(time_now, time_now + 3.months)
      end

      deleted_event_ids = Set[]
      meetup_gcal_ids = meetup_events.map &:gcal_id
      gcal_events.each do |gcal_event|
        is_active = gcal_event.status != 'cancelled'
        from_us = Meetalendar::MeetupApi::Event.gcal_id? gcal_event.id
        in_meetup = meetup_gcal_ids.include? gcal_event.id
        self.calendar_service.delete_event(calendar_id, gcal_event.id) if is_active and from_us and not in_meetup

        deleted_event_ids.add(gcal_event.id) if is_active and from_us and not in_meetup
      end
      deleted_events = meetup_events.select{|me| deleted_event_ids.include? me.gcal_id}
      meetalendar_instance.report_update_deleted_events(deleted_events)

      updated_event_ids = Set[]
      added_event_ids = Set[]
      gcal_ids = gcal_events.map &:id
      meetup_events.each do |event|
        if gcal_ids.include? event.gcal_id
          found_gcal_event = gcal_events.find { |e| e.id == event.gcal_id }
          next if event.equal_with_gcal_event? found_gcal_event and found_gcal_event.status != 'cancelled'
          self.calendar_service.update_event(calendar_id, event.gcal_id, event.gcal_event)
          
          updated_event_ids.add(event.gcal_id)
        else
          self.calendar_service.insert_event(calendar_id, event.gcal_event)

          added_event_ids.add(event.gcal_id)
        end
      end
      updated_events = meetup_events.select{|me| updated_event_ids.include? me.gcal_id}
      meetalendar_instance.report_update_updated_events(updated_events)
      added_events = meetup_events.select{|me| added_event_ids.include? me.gcal_id}
      meetalendar_instance.report_update_added_events(added_events)
      meetalendar_instance.save!
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
