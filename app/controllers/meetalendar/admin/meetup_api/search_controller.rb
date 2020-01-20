require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController
        def new
          @parameters = parameters
          if @parameters
            @groups = Meetalendar::MeetupApi.search_groups parameters
          else
            flash[:danger] = "Find groups parameters for Meetup query not set! (In order to find the right groups you must set the 'find groups parameters' for the meetup group search query in the frontend admin-meetup-groups area.)"
            redirect_to :admin_meetalendar_groups
          end
        rescue HTTPClient::BadResponseError => e
          raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
          Rails.logger.warn [e.message, *e.backtrace].join($/)
          flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
          redirect_to action: :show
        end

        private

        def parameters
          Meetalendar::Frame.meetup_find_groups_query
        end
      end
    end
  end
end