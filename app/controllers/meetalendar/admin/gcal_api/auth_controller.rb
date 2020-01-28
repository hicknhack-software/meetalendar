require 'rubygems'
require 'active_resource'

module Meetalendar
  module Admin
    module GcalApi
      class AuthController < Comfy::Admin::Cms::BaseController

        def new
          @gcal_auth_url = Meetalendar::GcalApi::Auth.url
        end

        def update
          Meetalendar::GcalApi::Auth.authorize_and_remember params[:key_code]
          flash[:success] = "Calendar successfully authorized."
          redirect_to :admin_meetalendar
        rescue Meetalendar::GcalApi::Auth::Error => e
          Rails.logger.warn [e.message, *e.backtrace].join($/)
          flash[:danger] = "Failed authorization: #{e.message}"
        ensure
          redirect_to action: :new unless performed?
        end

      end
    end
  end
end
