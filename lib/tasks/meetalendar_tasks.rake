namespace :meetalendar do
  desc 'Syncronize selected meetup groups events with the configured google calendar.'
  task :syncronize, [:google_calendar_id] => :environment do |task, args|
    Meetalendar::sync_calendar args[:google_calendar_id]
  end
end
