# frozen_string_literal: true

require "googleauth"

Meetalendar.configure do |config|
  # application layout to be used to index blog posts
  #   config.app_layout = 'comfy/meetalendar/application'

  # Number of posts per page. Default is 10
  #   config.posts_per_page = 10

  # Loading credentials for the meelanedar functionality
  ENV_MEETALENDAR_CREDENTIALS_FILEPATH ||= "MEETALENDAR_CREDENTIALS_FILEPATH".freeze
  Rails.logger.error("#{ENV_MEETALENDAR_CREDENTIALS_FILEPATH} is not set but needed!") if !ENV.has_key?(ENV_MEETALENDAR_CREDENTIALS_FILEPATH)
  MEETALENDAR_CREDENTIALS_FILEPATH ||= Comfy::Admin::Meetalendar::AuthCredential.expand_env(ENV[ENV_MEETALENDAR_CREDENTIALS_FILEPATH].to_s)

  File.open MEETALENDAR_CREDENTIALS_FILEPATH.to_s do |file|
    json = file.read
    all_credentials = MultiJson.load json
    MEETALENDAR_CREDENTIALS_MEETUP ||= all_credentials["meetup"]
    MEETALENDAR_CREDENTIALS_GOOGLE_CALENDAR_CLIENT_ID ||= Google::Auth::ClientId.from_hash all_credentials["google_calendar"]
  end
end
