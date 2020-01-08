class CreateMeetalendarGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :meetalendar_groups do |t|
      t.string :name
      t.integer :meetup_id, null: false
      t.string :approved_cities
      t.string :meetup_link

      t.index [:meetup_id], unique: true
      t.timestamps
    end
  end
end
