require 'httpclient'
require 'multi_json'

module Meetalendar
  module MeetupApi
    module Oauth
      OAUTH_URI = "https://secure.meetup.com/oauth2"
      ACCESS_URI = "#{OAUTH_URI}/access"
      AUTHORIZE_URI = "#{OAUTH_URI}/authorize"

      def self.tokens
        AuthCredential.for_auth('meetup')
      end

      def self.authorize_url(callback_uri)
        "#{AUTHORIZE_URI}?client_id=#{config["client_id"]}&response_type=code&redirect_uri=#{callback_uri}"
      end

      def self.create_auth(code, callback_uri)
        auth = JSON.parse HTTPClient.post_content ACCESS_URI, body: {
            'client_id': self.config["client_id"],
            'client_secret': self.config["client_secret"],
            'grant_type': 'authorization_code',
            "redirect_uri": callback_uri,
            'code': code,
        }
        store auth
      end

      def self.refresh
        auth = JSON.parse HTTPClient.post_content ACCESS_URI, body: {
            'client_id': self.config["client_id"],
            'client_secret': self.config["client_secret"],
            'grant_type': "refresh_token",
            'refresh_token': self.tokens.refresh_token
        }
        store auth
      end

      private

      def self.config
        Meetalendar.config.meetup_credentials
      end

      def self.store(auth)
        AuthCredential.store_auth('meetup', {
            'client_id': self.config["client_id"],
            'access_token': auth["access_token"],
            'refresh_token': auth["refresh_token"],
            'scope': '',
            'expiration_time_millis': auth["expires_in"] * 1000
        })
      end

    end
  end
end
