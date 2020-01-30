require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController
        def new
          respond_to do |format|
            format.html {              
              begin
                if Meetalendar::Frame.meetup_query_location_set?
                  @offset = 0
                  @per_page = per_page
                  @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_location_groups.merge({ page: @per_page, offset: @offset })
                else
                  flash[:danger] = "Location unset for Meetup query! (In order to find the right groups you must set the 'query location' for the meetup group search query in the frontend admin-meetup-groups area.)"
                  redirect_to :admin_meetalendar_groups
                end
              rescue ArgumentError => e
                flash[:danger] = e.exception.to_s
                redirect_to :admin_meetalendar_groups
              rescue HTTPClient::BadResponseError => e
                raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
                Rails.logger.warn [e.message, *e.backtrace].join($/)
                flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
                redirect_to action: :show
              end
            }
            format.js {
              @offset = params[:offset].to_i
              @per_page = per_page
              @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_location_groups.merge({ page: @per_page, offset: @offset })
              render 'load_more', layout: false, content_type: 'text/javascript'
            }
          end
        end

        private
        
        def per_page
          10
        end
      end
    end
  end
end
