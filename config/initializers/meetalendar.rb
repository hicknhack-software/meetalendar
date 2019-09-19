# frozen_string_literal: true

require "googleauth"

def expand_env(str)
  str.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) { ENV[$1] }
end

Meetalendar.configure do |config|
  # application layout to be used to index blog posts
  #   config.app_layout = 'comfy/meetalendar/application'

  # Number of posts per page. Default is 10
  #   config.posts_per_page = 10

  # Loading credentials for the meetalendar functionality
  MEETALENDAR_CREDENTIALS_FILEPATH ||= do 
    key = "MEETALENDAR_CREDENTIALS_FILEPATH".freeze
    Rails.logger.error("ENV #{key} is not set but needed!") unless ENV.has_key?(key)
    expand_env(ENV[key].to_s)
  end
  all_credentials = MultiJson.load(File.read(MEETALENDAR_CREDENTIALS_FILEPATH.to_s))
  MEETALENDAR_CREDENTIALS_MEETUP ||= all_credentials["meetup"]
  MEETALENDAR_CREDENTIALS_GOOGLE_CALENDAR_CLIENT_ID ||= Google::Auth::ClientId.from_hash all_credentials["google_calendar"]
end
