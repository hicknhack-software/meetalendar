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
                unless Meetalendar::Setting.present?
                  flash[:danger] = "Missing search settings!"
                  redirect_to :admin_meetalendar
                end
                @offset = 0
                @per_page = per_page
                @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Setting.instance.meetup_groups_query.merge(page: @per_page, offset: @offset)
              rescue HTTPClient::BadResponseError => e
                raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
                Rails.logger.warn [e.message, *e.backtrace].join($/)
                flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
                redirect_to :admin_meetalendar
              end
            }
            format.js {
              @offset = params[:offset].to_i
              @per_page = per_page
              @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Setting.instance.meetup_groups_query.merge(page: @per_page, offset: @offset)
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
