module Meetalendar
  class Admin::SettingsController < Comfy::Admin::Cms::BaseController

    def create
      update
    end

    def update
      begin
        Meetalendar::Setting.instance.update! update_params
        flash[:success] = "Settings updated"
        redirect_to :admin_meetalendar
      rescue ActiveRecord::RecordInvalid
        flash[:danger] = 'Failed to update Settings'
        redirect_to :admin_meetalendar
      rescue ArgumentError => exception
        flash[:danger] = "Failed to update Settings: #{exception.message}"
        redirect_to :admin_meetalendar
      end
    end

    private

    def update_params
      params.require(:setting).permit(:meetup_query_json, :report_to_emails, :report_every_xth_time)
    end
  end
end
