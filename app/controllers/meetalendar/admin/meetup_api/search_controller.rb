require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController

        def load_more
          @offset = params[:offset].to_i
          @per_page = per_page
          puts "##### @offset = " + @offset.to_s + " @per_page = " + @per_page.to_s

          @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_location_groups.merge({ page: @per_page, offset: @offset })
          render layout: false, content_type: 'text/javascript'
        end

        def new
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


        # def new
        #   respond_to do |format|
        #     format.html {
        #       puts "#####################################"
        #       puts "Went through .html"
              
        #       begin
        #         if Meetalendar::Frame.meetup_query_location_set?
        #           @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_location_groups
        #         else
        #           flash[:danger] = "Location unset for Meetup query! (In order to find the right groups you must set the 'query location' for the meetup group search query in the frontend admin-meetup-groups area.)"
        #           redirect_to :admin_meetalendar_groups
        #         end
        #       rescue ArgumentError => e
        #         flash[:danger] = e.exception.to_s
        #         redirect_to :admin_meetalendar_groups
        #       rescue HTTPClient::BadResponseError => e
        #         raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
        #         Rails.logger.warn [e.message, *e.backtrace].join($/)
        #         flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
        #         redirect_to action: :show
        #       end
        #     }
        #     format.json {
        #       puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        #       puts "Went through .json"
        #       puts "params[:page] " + params[:page].to_s

        #       @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_location_groups(params[:page])
        #       render json: @groups.to_json
        #     }
        #   end
        # end

        private
        
        def per_page
          10
        end
      end
    end
  end
end
