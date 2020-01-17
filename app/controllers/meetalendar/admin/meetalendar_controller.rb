module Meetalendar
  class Admin::MeetalendarController < Comfy::Admin::Cms::BaseController
    def parameters
      if params[:parameters].present?
        JSON.parse(params[:parameters])
      else
        {}
      end
    end

    def update
      flash[:success] = "New query parameters: #{parameters}"
      Meetalendar::Frame.meetup_query=(parameters)
      redirect_to :admin_meetalendar_groups
    end
  end
end
