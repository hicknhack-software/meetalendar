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

    raise ActiveRecord::RecordNotFound("No Setting present!") unless Meetalendar::Setting.present?

    upcoming_events = Meetalendar::MeetupApi.find_upcoming_events(Meetalendar::Setting.instance.meetup_events_query).select do |event|
      event.start_time.between?(time_now, time_now + 3.months) and group_ids.include?(event.group_id)
    end

    series_events = upcoming_events.select(&:series?).map do |series|
      Meetalendar::MeetupApi.group_urlname_events(series.group_urlname, page: 5).select do |event|
        event.start_time.between?(time_now, time_now + 3.months)
      end
    end.flatten

    (upcoming_events + series_events).uniq(&:id).select do |event|
      approved_cities = group_approved_cities.dig(event.group_id) || []
      approved_cities.empty? or not event.venue? or approved_cities.include? event.city.downcase
    end
  end
end
