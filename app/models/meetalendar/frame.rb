class Meetalendar::Frame < ApplicationRecord
  self.table_name = "meetalendar_frames"
  serialize :meetup_query_location, JSON

  def self.meetup_query_location_groups(page_nr = 0)
    (JSON.parse(self.first&.meetup_query_location.to_json, symbolize_names: true) || {}).map do |parameter|
      if parameter[0] == :topic_category
        parameter[0] = :category
      end
      parameter
    end.to_h.merge({order: 'distance', page: 10, offset: page_nr,
      fields: 'last_event,past_event_count,upcoming_event_count,proposed_event_count,draft_event_count',
      only: 'id,name,link,last_event,past_event_count,upcoming_event_count,proposed_event_count,draft_event_count,next_event,city'})
  end

  def self.meetup_query_location_events
    (JSON.parse(self.first&.meetup_query_location.to_json, symbolize_names: true) || {}).map do |parameter|
      if parameter[0] == :category
        parameter[0] = :topic_category
      end
      parameter
  end.to_h.merge({page: 200, fields: 'series',
    only: 'events.id,events.name,events.description,events.link,events.time,events.duration,events.group.name,events.venue'})
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
