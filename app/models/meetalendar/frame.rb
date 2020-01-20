class Meetalendar::Frame < ApplicationRecord
  self.table_name = "meetalendar_frames"
  serialize :meetup_find_groups_query, JSON
  serialize :meetup_upcoming_events_query, JSON

  def self.meetup_find_groups_query
    JSON.parse(self.first&.meetup_find_groups_query.to_json, symbolize_names: true)
  end

  def self.meetup_find_groups_query=(meetup_find_groups_query)
    (self.first || self.new).update! meetup_find_groups_query: meetup_find_groups_query
  end

  def self.meetup_upcoming_events_query
    JSON.parse(self.first&.meetup_upcoming_events_query.to_json, symbolize_names: true)
  end

  def self.meetup_upcoming_events_query=(meetup_upcoming_events_query)
    (self.first || self.new).update! meetup_upcoming_events_query: meetup_upcoming_events_query
  end
end
