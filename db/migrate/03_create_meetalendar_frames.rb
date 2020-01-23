class CreateMeetalendarFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :meetalendar_frames do |t|
      t.string :meetup_query_location

      t.timestamps
    end
  end
end