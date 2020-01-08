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
          key_code = params_permit_key_code[:key_code]
          Meetalendar::GcalApi::Auth.authorize_and_remember(key_code)
          flash[:success] = "Calendar successfully authorized."
          redirect_to meetalendar_admin_group_path
        rescue ::ActiveResource::UnauthorizedAccess => exception
          flash[:error] = exception.message.to_s
          redirect_to action: :new
        rescue => ex
          Rails.logger.error "failed to authorize calendar: #{ex.message}"
          redirect_to action: :new
        end

        private

        def params_permit_key_code
          params.permit(:key_code)
        end

      end
    end
  end
end
