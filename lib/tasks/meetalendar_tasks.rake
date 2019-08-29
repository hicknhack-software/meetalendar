namespace :meetalendar do
  desc 'Syncronize selected meetup groups events with the configured google calendar.'
  task :syncronize => :environment do
    require 'comfy/admin/meetalendar/meetups_calendar_syncer'
    Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.sync_meetups_to_calendar(Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.gather_meetups_in_approved_cities(Time.now))
  end


  # desc 'Syncronize selected meetup groups events with the configured google calendar.'
  # task :testoncli => :environment do
  #   require 'comfy/admin/meetalendar/meetups_calendar_syncer'
  #   Comfy::Admin::Meetalendar::MeetupsCalendarSyncer.gather_meetups_in_approved_cities(Time.now)
  # end
end
