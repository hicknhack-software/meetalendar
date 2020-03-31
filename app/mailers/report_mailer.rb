class ReportMailer < ActionMailer::Base
  default from: 'notifications@hicknhack-software.com'

  def email_report(email, report)
    @added_and_deleted_grouped = report[Meetalendar::Setting::ADDED_AND_DELETED]&.group_by do |k, v|
      v["group_id"]
    end

    @deleted_grouped = report[Meetalendar::Setting::DELETED]&.group_by do |k, v|
      v["group_id"]
    end

    @added_grouped = report[Meetalendar::Setting::ADDED]&.group_by do |k, v|
      v["group_id"]
    end

    @updated_grouped = report[Meetalendar::Setting::UPDATED]&.group_by do |k, v|
      v["group_id"]
    end

    mail(to: email, subject: 'Welcome to My Awesome Test-Mail')
  end
end
