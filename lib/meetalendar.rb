# frozen_string_literal: true

require_relative "meetalendar/version"
require_relative "meetalendar/engine"
require_relative "meetalendar/configuration"
require_relative "meetalendar/routing"

module Meetalendar

  class << self

    # Modify Blog configuration
    # Example:
    #   Meetalendar.configure do |config|
    #     config.posts_per_page = 5
    #   end
    def configure
      yield configuration
    end

    # Accessor for Meetalendar::Configuration
    def configuration
      @configuration ||= Meetalendar::Configuration.new
    end
    alias config configuration

    def sync_calendar(gcal_id = nil)
      if Meetalendar::MeetupApi::Oauth.tokens.nil?
        raise ArgumentError, 'Meetup auth token not set.'
      end
      if Meetalendar::GcalApi::Auth.authorize.nil?
        raise ArgumentError, 'Google Calendar auth token not set.'
      end

      gcal_id ||= Meetalendar.config.google_calendar_id
      time_now = Time.now
      time_limit = time_now + 1.year
      upcoming_events = Meetalendar::Group.all_upcoming_events time_now
      Meetalendar::GcalSync.update_events upcoming_events, gcal_id, time_now, time_limit

      meetalendar_instance = Meetalendar::Setting.instance
      if meetalendar_instance.next_report?
        self.send_report_to_mails(meetalendar_instance.report_to_emails_array, meetalendar_instance.current_report)
        meetalendar_instance.next_report_in_reset
      else
        meetalendar_instance.next_report_in_decrease
      end
      meetalendar_instance.save!
    end

    def send_report_to_mails(emails, report)
      emails.each do |email|
        ReportMailer.email_report(email, report).deliver_now
      end
    end
  end

end
