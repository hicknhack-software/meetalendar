require 'attr_encrypted'

class Comfy::Admin::Meetalendar::AuthCredential < ApplicationRecord
  self.table_name = "meetalendar_auth_credentials"

  # TODO(Schau): There might be a better place for this function
  def self.expand_env(str)
    str.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) { ENV[$1] }
  end

  attr_encrypted :access_token, key: Rails.application.key_generator.generate_key('access_token', 32)
  attr_encrypted :refresh_token, key: Rails.application.key_generator.generate_key('refresh_token', 32)

  def scope
    # NOTE(Schau): Scope expected to be a json parsable string that results in an array.
    parsed_scope = JSON.parse(self.scope_json)
    parsed_scope = parsed_scope.empty? ? [] : parsed_scope
  end
  def scope=(new_scope)
    self.scope_json = new_scope.to_json.to_s
  end
end
