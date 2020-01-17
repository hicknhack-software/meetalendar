require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module MeetupApi
      class OauthController < Comfy::Admin::Cms::BaseController

        def new
          redirect_to Meetalendar::MeetupApi::Oauth.authorize_url(callback_admin_meetalendar_meetup_api_oauth_url)
        end

        def callback
          Meetalendar::MeetupApi::Oauth.create_auth(params[:code], callback_admin_meetalendar_meetup_api_oauth_url)
          flash[:success] = "Meetup.com API successfully authorized."
        rescue HTTPClient::BadResponseError => e
          raise unless e.res&.status == HTTP::Status::UNAUTHORIZED
          Rails.logger.warn [e.message, *e.backtrace].join($/)
          flash[:danger] = e.message.to_s
        ensure
          redirect_to admin_meetalendar_groups_path unless performed?
        end

        def failure
          # TODO(Schau): Possibly there are arguments given to this function/route containing more info on why meetup api authorization failed.
          flash[:error] = "Meetup.com API authorization failed."
          redirect_to admin_meetalendar_groups_path
        end

      end
    end
  end
end
