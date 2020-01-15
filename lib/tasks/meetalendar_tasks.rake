namespace :meetalendar do
  desc 'Synchronize selected meetup groups events with the configured google calendar.'
  task :synchronize, [:google_calendar_id] => :environment do |task, args|
    Meetalendar::sync_calendar args[:google_calendar_id]
  end
end
