class CreateMeetalendarAuthCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :meetalendar_auth_credentials do |t|
      t.string :client_id
      t.string :encrypted_access_token
      t.string :encrypted_access_token_iv
      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv
      t.string :scope_json
      t.integer :expiration_time_millis
      t.string :auth_id

      t.timestamps
    end
  end
end
