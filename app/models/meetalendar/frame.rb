class Meetalendar::Frame < ApplicationRecord
  self.table_name = "meetalendar_frames"
  serialize :meetup_query_location, JSON

  def self.meetup_query_groups
    (self.meetup_query_location || {}).transform_keys do |key|
      key == :topic_category && :category || key
    end.merge(fields: 'last_event', order: 'distance', page: 200)
  end

  def self.meetup_query_events
    (self.meetup_query_location || {}).transform_keys do |key|
      key == :category && :topic_category || key
    end.merge(order: 'time', page: 200, series: true)
  end

  def self.meetup_query_location
    self.first&.meetup_query_location&.symbolize_keys
  end

  def self.meetup_query_location?
    self.first != nil
  end

  def self.meetup_query_location=(meetup_query_location)
    (self.first || self.new).update! meetup_query_location: meetup_query_location
  end
end
