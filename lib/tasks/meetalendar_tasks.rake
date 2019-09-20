namespace :meetalendar do
  desc 'Syncronize selected meetup groups events with the configured google calendar.'
  task :syncronize, [:google_calendar_id] => :environment do |task, args|
    require 'meetalendar/meetups_calendar_syncer'
    events = Meetalendar::MeetupsCalendarSyncer.gather_selected_events(Time.now)
    Meetalendar::MeetupsCalendarSyncer.sync_meetups_to_calendar(events, args[:google_calendar_id], Time.now, Time.now + 1.year)
  end
end
