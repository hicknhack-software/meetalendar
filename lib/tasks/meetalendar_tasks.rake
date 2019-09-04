namespace :meetalendar do
  desc 'Syncronize selected meetup groups events with the configured google calendar.'
  task :syncronize, [:google_calendar_id] => :environment do |task, args|
    require 'comfy/admin/meetalendar/meetups_calendar_syncer'
    Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.sync_meetups_to_calendar(Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.gather_selected_events(Time.now), args[:google_calendar_id], Time.now, Time.now + 1.year)
  end
end
