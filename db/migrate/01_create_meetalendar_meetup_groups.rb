class CreateMeetalendarMeetupGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :meetalendar_meetup_groups do |t|
      t.string :name
      t.integer :group_id, null: false
      t.string :approved_cities
      t.string :group_link

      t.index [:group_id], unique: true
      t.timestamps
    end
  end
end
