require "googleauth/token_store"

module Google
  module Auth
    module Stores
      class DbTokenStore < Google::Auth::TokenStore
        # (see Google::Auth::Stores::TokenStore#load)
        def load id
          credentials = Comfy::Admin::Meetalendar::AuthCredential.find_by(auth_id: id)
          !credentials.nil? ?
          {
            # NOTE(Schau): The encryption algorithm must decipher the encrypted tokens! It does so in this function call: credentials.access_token and credentials.refresh_token
            auth_id: credentials.auth_id,
            client_id: credentials.client_id,
            access_token: credentials.access_token,
            refresh_token: credentials.refresh_token,
            scope: credentials.scope,
            expiration_time_millis: credentials.expiration_time_millis
          }.to_json.to_s
          : nil
        end

        # (see Google::Auth::Stores::TokenStore#store)
        def store id, token
          token_hash = JSON.parse(token).symbolize_keys
          Comfy::Admin::Meetalendar::AuthCredential.find_or_initialize_by(auth_id: id).update(token_hash)
        end

        # (see Google::Auth::Stores::TokenStore#delete)
        def delete id
          credentials = User.find_by(auth_id: id)
          credentials.destroy
        end
      end
    end
  end
end
