require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class OauthController < Comfy::Admin::Cms::BaseController

        def new
          redirect_to Meetalendar::MeetupApi::Oauth.authorize_url(callback_meetalendar_admin_meetup_api_oauth_url)
        end

        def callback
          begin
            Meetalendar::MeetupApi::Oauth.create_auth(params[:code], callback_meetalendar_admin_meetup_api_oauth_url)
            flash[:success] = "Meetup.com API successfully authorized."
          rescue ::ActiveResource::ClientError => ex
            flash[:error] = ex.message.to_s
          rescue => ex
            Rails.logger.error "failed to authorize Meetup.com API: #{ex.message}"
          end
          redirect_to meetalendar_admin_groups_path
        end

        def failure
          # TODO(Schau): Possibly there are arguments given to this function/route containing more info on why meetup api authorization failed.
          flash[:error] = "Meetup.com API authorization failed."
          redirect_to action: :index
        end

      end
    end
  end
end
