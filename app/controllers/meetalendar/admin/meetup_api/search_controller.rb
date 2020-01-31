require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController
        def new
          respond_to do |format|
            format.html {
              unless Meetalendar::Setting.present?
                flash[:danger] = "Missing search settings!"
                redirect_to :admin_meetalendar
              end
              @offset = 0
              @per_page = per_page
              @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Frame.meetup_query_location_groups.merge({ page: @per_page, offset: @offset })
            rescue HTTPClient::BadResponseError => e
              raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
              Rails.logger.warn [e.message, *e.backtrace].join($/)
              flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
              redirect_to :admin_meetalendar
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
