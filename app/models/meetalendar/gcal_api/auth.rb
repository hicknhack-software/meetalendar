require 'rubygems'
require 'active_resource'

require "google/apis/calendar_v3"
require "googleauth"

module Meetalendar
  module GcalApi
    module Auth
      GOOGLE_CALENDAR_AUTH_OOB_URI ||= "urn:ietf:wg:oauth:2.0:oob".freeze
      GOOGLE_CALENDAR_AUTH_APPLICATION_NAME ||= "Google Calendar API Ruby MeetupSync".freeze
      GOOGLE_CALENDAR_AUTH_SCOPE ||= Google::Apis::CalendarV3::AUTH_CALENDAR_EVENTS.freeze

      def self.prepare_authorizer
        client_id = Google::Auth::ClientId.from_hash Meetalendar.config.google_calendar_credentials
        token_store = DbTokenStore.new
        Google::Auth::UserAuthorizer.new client_id, GOOGLE_CALENDAR_AUTH_SCOPE, token_store
      end

      def self.url
        self.prepare_authorizer.get_authorization_url base_url: GOOGLE_CALENDAR_AUTH_OOB_URI
      end

      def self.authorize_and_remember(key_code)
        authorizer = self.prepare_authorizer
        user_id = "default"

        authorizer.get_and_store_credentials_from_code(user_id: user_id, code: key_code, base_url: GOOGLE_CALENDAR_AUTH_OOB_URI)
      rescue => exception
        Rails.logger.error "Authorization of google calendar api failed with exception: #{exception.message}"
        raise ::ActiveResource::UnauthorizedAccess, "Authorization at google calendar failed."
      end

      def self.authorize
        authorizer = self.prepare_authorizer
        user_id = "default"
        credentials = authorizer.get_credentials user_id

        if credentials.nil?
          Rails.logger.error "Authorization failed as no google calendar api credentials are present."
          raise ::ActiveResource::UnauthorizedAccess, "Please go to: <host>/admin/meetups in the admin interface of the website and renew the authorization of the calendar api."
        end
        credentials
      end

    end

  end
end
