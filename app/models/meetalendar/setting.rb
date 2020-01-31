class Meetalendar::Setting < ApplicationRecord
  self.table_name = "meetalendar_settings"
  serialize :meetup_query, HashWithIndifferentAccess

  def self.instance
    (self.first || self.new)
  end
  def self.present?
    self.first != nil
  end

  def meetup_groups_query
    self.meetup_query.transform_keys do |key|
      key == :topic_category && :category || key
    end.merge(order: 'distance',
      fields: 'last_event,past_event_count,upcoming_event_count,proposed_event_count,draft_event_count',
      only: 'id,name,link,last_event,past_event_count,upcoming_event_count,proposed_event_count,draft_event_count,next_event,city')
  end

  def meetup_events_query
    self.meetup_query.transform_keys do |key|
      key == :category && :topic_category || key
    end.merge(page: 200, fields: 'series',
      only: 'events.id,events.name,events.description,events.link,events.time,events.duration,events.group.name,events.venue')
  end

  def meetup_query
    unless super.empty?; super else meetup_query_default end
  end

  def meetup_query_default
    {category: 0, lat: 0.0, lon: 0.0, radius: 0}
  end

  def meetup_query_json
    JSON.pretty_generate(self.meetup_query)
  end

  def meetup_query_json=(json)
    self.meetup_query = HashWithIndifferentAccess.new(JSON.parse json)
  end
end