class Meetalendar::Group < ApplicationRecord
  self.table_name = "meetalendar_groups"
  serialize :approved_cities, Array

  def approved_cities=(value)
    value = value.split(%r{\s+|\s*,\s*}) if value.kind_of? String
    super(value.map(&:downcase).sort)
  end

  def self.all_upcoming_events(time_now = nil)
    time_now ||= Time.now
    groups = self.all
    group_ids = groups.map &:meetup_id
    group_approved_cities = groups.map do |group|
      ["#{group.meetup_id}", group.approved_cities]
    end.to_h

    upcoming_groups_events = Meetalendar::MeetupApi.find_upcoming_events({'page': 200, 'fields': 'series'}).select do |event|
      event.start_time > time_now and group_ids.include?(event.group_id)
    end

    upcoming_groups_series_events = upcoming_groups_events.select do |event|
      event.is_series?
    end.map do |event|
      Meetalendar::MeetupApi.group_urlname_events(event.group_urlname, {'page': 200})
    end.flatten
    
    concated_uniq_upcoming_events = upcoming_groups_events.concat(upcoming_groups_series_events).uniq{ |event| event.id }
    
    concated_uniq_upcoming_events.select do |event|
      approved_cities = group_approved_cities.dig(event.group_id) || []
      approved_cities.empty? or not event.venue? or approved_cities.include? event.city.downcase
    end
  end
end
