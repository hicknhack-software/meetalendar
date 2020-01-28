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
    end.merge(fields: ['last_event'], order: 'distance', page: 200)
  end

  def meetup_events_query
    self.meetup_query.transform_keys do |key|
      key == :category && :topic_category || key
    end.merge(fields: ['series'], order: 'best', page: 200) # order time skips series events
  end

  def meetup_query
    super || meetup_query_default
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
