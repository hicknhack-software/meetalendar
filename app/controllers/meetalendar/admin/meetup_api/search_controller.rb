require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class SearchController < Comfy::Admin::Cms::BaseController

        def show
        end

        def new
          @groups = Meetalendar::MeetupApi.search_groups JSON.parse(search_params[:parameters])
        rescue ::HTTPClient::BadResponseError => bad
          if bad.res.status == HTTP::Status::UNAUTHORIZED
            flash[:error] = "Could not load groups and events from meetup. Is the client authorized to the Meetup API?"
            redirect_to action: :show
          else
            raise
          end
        end

        private

        def search_params
          params.permit(:parameters)
        end

      end
    end
  end
end