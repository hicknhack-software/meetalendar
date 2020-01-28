require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController
        def new
          unless Meetalendar::Setting.present?
            flash[:danger] = "Missing search settings!"
            redirect_to :admin_meetalendar
          end
          @group_ids = Meetalendar::Group.pluck(:meetup_id)
          @groups = Meetalendar::MeetupApi.search_groups Meetalendar::Setting.instance.meetup_groups_query do |group|
            not @group_ids.include? group.id
          end
        rescue HTTPClient::BadResponseError => e
          raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
          Rails.logger.warn [e.message, *e.backtrace].join($/)
          flash[:danger] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
          redirect_to :admin_meetalendar
        end
      end
    end
  end
end
