namespace :meetalendar do
  desc 'Syncronize selected meetup groups events with the configured google calendar.'
  task :syncronize, [:google_calendar_id] => :environment do |task, args|
    gcal_id = args[:google_calendar_id]
    time_now = Time.now
    time_limit = time_now + 1.year
    upcoming_events = Meetalendar::Group.all_upcoming_events time_now
    Meetalendar::GcalSync.update_events upcoming_events, gcal_id, time_now, time_limit
  end
end
