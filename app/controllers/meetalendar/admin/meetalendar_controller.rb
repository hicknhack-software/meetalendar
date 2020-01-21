module Meetalendar
  class Admin::MeetalendarController < Comfy::Admin::Cms::BaseController
    def update
      if location_parameters_present?
        flash[:success] = "New location parameters: #{location_parameters}"
        Meetalendar::Frame.meetup_query_location=(location_parameters)
      else
        flash[:error] = "No location parameters present in update call."
      end
      redirect_to :admin_meetalendar_groups
    end

    protected

    def location_parameters_present?
      params[:location_parameters].present?
    end

    def location_parameters
      if location_parameters_present?
        JSON.parse(params[:location_parameters])
      else
        {}
      end
    end
  end
end
