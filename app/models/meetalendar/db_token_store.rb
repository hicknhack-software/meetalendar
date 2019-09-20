require "googleauth/token_store"

class Meetalendar::DbTokenStore < Google::Auth::TokenStore
  # To store credentials encrypted we store every field

  # (see Google::Auth::Stores::TokenStore#load)
  def load id
    AuthCredential.for_auth(id)&.as_token
  end

  # (see Google::Auth::Stores::TokenStore#store)
  def store(id, token)
    AuthCredential.store_auth(id, JSON.parse(token).symbolize_keys)
  end

  # (see Google::Auth::Stores::TokenStore#delete)
  def delete id
    AuthCredential.for_auth(id).destroy
  end
end
