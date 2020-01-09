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

    Meetalendar::MeetupApi.find_upcoming_events({'page': 200}).select do |event|
      event.start_time > time_now and group_ids.include?(event.group_id)
    end.select do |event|
      approved_cities = group_approved_cities.dig(event.group_id) || []
      approved_cities.empty? or not event.venue? or approved_cities.include? event.city.downcase
    end
  end
end
