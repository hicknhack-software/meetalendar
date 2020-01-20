class CreateMeetalendarFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :meetalendar_frames do |t|
      t.string :meetup_find_groups_query
      t.string :meetup_upcoming_events_query

      t.timestamps
    end
  end
end
