require 'httpclient'
require 'multi_json'

module Meetalendar
  module MeetupApi
    module Oauth

      def self.tokens
        AuthCredential.for_auth('meetup')
      end

      def self.authorize_url(callback_uri)
        "https://secure.meetup.com/oauth2/authorize" +
            "?client_id=#{self.config["client_id"]}" +
            "&response_type=code" +
            "&redirect_uri=#{callback_uri}"
      end

      def self.create_auth(code, callback_uri)
        request_uri = "https://secure.meetup.com/oauth2/access"
        request_query_hash = {
            'client_id': self.config["client_id"],
            'client_secret': self.config["client_secret"],
            'grant_type': 'authorization_code',
            "redirect_uri": callback_uri,
            'code': code,
        }

        response = JSON.parse(HTTPClient.post_content(request_uri, request_query_hash))

        AuthCredential.store_auth('meetup', {
            'client_id': self.config["client_id"],
            'access_token': response["access_token"],
            'refresh_token': response["refresh_token"],
            'scope': '',
            'expiration_time_millis': response["expires_in"] * 1000
        })
      rescue => ex
        Rails.logger.error "Failed to authorize Meetup API. Exception in callback: #{ex.message}"
        raise ::ActiveResource::ClientError, "Failed to authorize Meetup API."
      end

      def self.refresh
        request_uri = "https://secure.meetup.com/oauth2/access"
        request_query_args = {
            'client_id': self.config["client_id"],
            'client_secret': self.config["client_secret"],
            'grant_type': "refresh_token",
            'refresh_token': self.tokens.refresh_token
        }
        post_return = HTTPClient.post_content(request_uri, request_query_args)

        if post_return.nil? || post_return.status == Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized]
          Rails.logger.error "Authorization with current token failed and token could not be refreshed. Was authorization to meetup api revoked?"
          raise ::ActiveResource::UnauthorizedAccess, "To access this path you need to have authenticated the Meetup API successfully."
        end

        response = JSON.parse(post_return.to_s)
        AuthCredential.store_auth('meetup', {
            'client_id': self.config['client_id'],
            'access_token': response['access_token'],
            'refresh_token': response['refresh_token'],
            'scope': '',
            'expiration_time_millis': response['expires_in'] * 1000
        })
      end

      private

      def self.config
        Meetalendar.config.meetup_credentials
      end

    end
  end
end
