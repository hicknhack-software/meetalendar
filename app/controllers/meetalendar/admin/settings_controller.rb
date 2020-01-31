module Meetalendar
  class Admin::SettingsController < Comfy::Admin::Cms::BaseController

    def create
      update
    end

    def update
      Meetalendar::Setting.instance.update! update_params
      flash[:success] = "Settings updated"
      redirect_to :admin_meetalendar
    rescue ActiveRecord::RecordInvalid
      flash.now[:danger] = 'Failed to update Settings'
      redirect_to :admin_meetalendar
    end

    private

    def update_params
      params.require(:setting).permit(:meetup_query_json)
    end
  end
end
