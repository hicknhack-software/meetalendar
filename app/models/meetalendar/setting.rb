class Meetalendar::Setting < ApplicationRecord
  self.table_name = "meetalendar_settings"
  serialize :meetup_query, HashWithIndifferentAccess
  serialize :report, HashWithIndifferentAccess

  ADDED_AND_DELETED = "added_and_deleted"
  DELETED = "deleted"
  ADDED = "added"
  UPDATED = "updated"

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

  def report_to_emails
    self.report_emails
  end

  def report_to_emails_array
    self.report_emails.split(/\s*,\s*/)
  end

  def report_to_emails=(emails)
    split_emails = emails.split(/\s*,\s*/)

    wrong_emails = split_emails.select{|se| !se.match(URI::MailTo::EMAIL_REGEXP)}
    raise ArgumentError, "These emails are not valid: #{wrong_emails.join(", ")}" if wrong_emails.length != 0

    checked_emails = split_emails.select{|se| se.match(URI::MailTo::EMAIL_REGEXP)}
    self.report_emails = checked_emails.join(", ")
  end

  def report_every_xth_time
    report_every
  end

  def report_every_xth_time=(every_xth_time)
    self.report_every = every_xth_time
    self.report_in = 0
  end

  def next_report?
    self.next_report_in <= 0
  end

  def next_report_in
    report_in
  end

  def next_report_in_reset
    self.report_in = report_every - 1
  end

  def next_report_in_decrease
    self.report_in -= 1
  end

  def current_report
    if self.report.empty?
      self.report_reset
    end
    JSON.parse(JSON.pretty_generate(self.report))
  end

  private def current_report=(json)
    self.report = HashWithIndifferentAccess.new(JSON.parse(JSON.pretty_generate json))
  end

  # NOTE(Schau): Maybe i want to introduce some sort of string constants for these hash keys...
  def report_reset
    self.report = HashWithIndifferentAccess.new(JSON.parse "{'#{ADDED_AND_DELETED}': {}, '#{DELETED}': {}, '#{added}': {}, '#{UPDATED}': {}}")
  end

  def event_to_report_hash(event)
    {
      "name": event.name,
      "start": event.start_time,
      "link": event.link,
      "group_id": event.group_id,
      "group_name": event.group_name
    }
  end

  def report_update_added_and_deleted_events(added_and_deleted_events)
    report_to_update = self.current_report
    added_and_deleted_events.each do |added_and_deleted_event|
      report_to_update[ADDED_AND_DELETED]["#{added_and_deleted_event.gcal_id}"] = event_to_report_hash(added_and_deleted_event)
    end
    self.current_report = report_to_update
  end

  def report_update_deleted_events(deleted_events)
    report_to_update = self.current_report

    deleted_events.each do |deleted_event|
      report_to_update[DELETED]["#{deleted_event.gcal_id}"] = event_to_report_hash(deleted_event)
    end

    deleted_events_gcal_ids = deleted_events.map &:gcal_id
    added_and_deleted_gcal_ids = Set[]
    report_to_update[ADDED]&.each do |report_added|
      in_report_added = deleted_events_gcal_ids.include? report_added.first
      added_and_deleted_gcal_ids.add(report_added.first) if in_report_added
    end
    self.report_update_added_and_deleted_events(deleted_events.select{|de| added_and_deleted_gcal_ids.include? de.gcal_id})

    added_and_deleted_gcal_ids.each do |aad|
      report_to_update[ADDED].delete(aad)
    end

    self.current_report = report_to_update
  end

  def report_update_updated_events(updated_events)
    report_to_update = self.current_report
    updated_events.each do |updated_event|
      report_to_update[UPDATED]["#{updated_event.gcal_id}"] = event_to_report_hash(updated_event)
    end
    self.current_report = report_to_update
  end

  def report_update_added_events(added_events)
    report_to_update = self.current_report

    added_events.each do |added_event|
      report_to_update[ADDED]["#{added_event.gcal_id}"] = event_to_report_hash(added_event)
    end

    added_events_gcal_ids = added_events.map &:gcal_id
    added_and_deleted_gcal_ids = Set[]
    report_to_update[DELETED]&.each do |report_deleted|
      in_report_deleted = added_events_gcal_ids.include? report_deleted.first
      added_and_deleted_gcal_ids.add(report_deleted.first) if in_report_deleted
    end
    self.report_update_added_and_deleted_events(added_events.select{|ae| added_and_deleted_gcal_ids.include? ae.gcal_id})

    added_and_deleted_gcal_ids.each do |aad|
      report_to_update[DELETED].delete(aad)
    end

    self.current_report = report_to_update
  end
end
