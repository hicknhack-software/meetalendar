class Meetalendar::Frame < ApplicationRecord
  self.table_name = "meetalendar_frames"
  serialize :meetup_query, JSON

  def self.meetup_query
    self.first&.meetup_query
  end

  def self.meetup_query=(meetup_query)
    (self.first || self.new).update! meetup_query: meetup_query
  end
end
