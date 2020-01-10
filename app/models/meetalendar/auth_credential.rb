require 'attr_encrypted'

class Meetalendar::AuthCredential < ApplicationRecord
  self.table_name = "meetalendar_auth_credentials"

  attr_encrypted :access_token, key: Rails.application.key_generator.generate_key('access_token', 32)
  attr_encrypted :refresh_token, key: Rails.application.key_generator.generate_key('refresh_token', 32)

  def scope
    JSON.parse(self.scope_json) || []
  end
  def scope=(new_scope)
    self.scope_json = new_scope.to_json.to_s
  end

  def self.for_auth(id)
    self.find_by auth_id: id
  end

  def self.store_auth(id, attributes)
    self.find_or_initialize_by(auth_id: id).update! attributes
  end

  def as_token
    {
      auth_id: auth_id,
      client_id: client_id,
      access_token: access_token,
      refresh_token: refresh_token,
      scope: scope,
      expiration_time_millis: expiration_time_millis
    }.to_json
  end
end
