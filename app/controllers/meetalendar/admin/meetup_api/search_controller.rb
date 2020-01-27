require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController
        def new
          unless Meetalendar::Frame.meetup_query_location?
            flash[:danger] = "Location unset for Meetup query! (In order to find the right groups you must set the 'query location' for the meetup group search query in the frontend admin-meetup-groups area.)"
            redirect_to :admin_meetalendar_groups
          end
          @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_groups
        rescue HTTPClient::BadResponseError => e
          raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
          Rails.logger.warn [e.message, *e.backtrace].join($/)
          flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
          redirect_to action: :show
        end
      end
    end
  end
end
