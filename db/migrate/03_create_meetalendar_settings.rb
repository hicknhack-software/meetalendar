class CreateMeetalendarSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :meetalendar_settings do |t|
      t.string :meetup_query
      t.string :report
      t.string :report_emails
      t.integer :report_every
      t.integer :report_in

      t.timestamps
    end
  end
end
