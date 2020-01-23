class Meetalendar::Frame < ApplicationRecord
  self.table_name = "meetalendar_frames"
  serialize :meetup_query_location, JSON

  def self.meetup_query_location_groups
    (JSON.parse(self.first&.meetup_query_location.to_json, symbolize_names: true) || {}).map do |parameter|
      if parameter[0] == :topic_category
        parameter[0] = :category
      end
      parameter
    end.to_h.merge({fields: 'last_event', order: 'distance', page: 200})
  end

  def self.meetup_query_location_events
    (JSON.parse(self.first&.meetup_query_location.to_json, symbolize_names: true) || {}).map do |parameter|
      if parameter[0] == :category
        parameter[0] = :topic_category
      end
      parameter
    end.to_h.merge({order: 'time', page: 200, series: true})
  end

  def self.meetup_query_location
    JSON.parse(self.first&.meetup_query_location.to_json, symbolize_names: true)
  end

  def self.meetup_query_location_set?
    self.first != nil
  end

  def self.meetup_query_location=(meetup_query_location)
    (self.first || self.new).update! meetup_query_location: meetup_query_location
  end
end
