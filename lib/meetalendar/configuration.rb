# frozen_string_literal: true

module Meetalendar
  class Configuration
    attr_accessor :credentials_path
    attr_accessor :meetup_credentials
    attr_accessor :google_calendar_credentials

    # Configuration defaults
    def initialize
      @credentials_path = ENV['MEETALENDAR_CREDENTIALS_FILEPATH'] || Rails.root.join('config', 'meetalender_credentials.json')
      @meetup_credentials = nil
      @google_calendar_credentials = nil
    end

    def meetup_credentials
      @meetup_credentials ||= json_credentials['meetup']
    end

    def google_calendar_credentials
      @google_calendar_credentials ||= json_credentials['google_calendar']
    end

    private

    def json_credentials
      @json_credentials ||= JSON.parse File.read(@credentials_path)
    end
  end
end
