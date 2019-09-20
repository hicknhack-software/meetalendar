# frozen_string_literal: true

Meetalendar.configure do |config|
  # path to credentials.json for the meetalendar functionality
  #   config.credentials_path = ENV['MEETALENDAR_CREDENTIALS_FILEPATH'] || Rails.root.join('config', 'meetalender_credentials.json')
  #
  # credentials usually fetched from the credentials_path
  #   config.meetup_credentials = JSON.load(config.credentials_path)['meetup']
  #   config.google_calendar_credentials = JSON.load(config.credentials_path)['google_calendar']
end
