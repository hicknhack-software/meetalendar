module Meetalendar
  class Admin::MeetalendarController < Comfy::Admin::Cms::BaseController
    def update
      if find_groups_parameters_present?
        flash[:success] = "New find groups parameters: #{find_groups_parameters}"
        Meetalendar::Frame.meetup_find_groups_query=(find_groups_parameters)
      elsif upcoming_events_parameters_present?
        flash[:success] = "New upcoming events parameters: #{upcoming_events_parameters}"
        Meetalendar::Frame.meetup_upcoming_events_query=(upcoming_events_parameters)
      end
      redirect_to :admin_meetalendar_groups
    end

    protected

    def find_groups_parameters_present?
      params[:find_groups_parameters].present?
    end
    
    def find_groups_parameters
      if params[:find_groups_parameters].present?
        JSON.parse(params[:find_groups_parameters])
      else
        {}
      end
    end

    def upcoming_events_parameters_present?
      params[:upcoming_events_parameters].present?
    end

    def upcoming_events_parameters
      if params[:upcoming_events_parameters].present?
        JSON.parse(params[:upcoming_events_parameters])
      else
        {}
      end
    end

  end
end
