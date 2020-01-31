module Meetalendar
  class Admin::HomeController < Comfy::Admin::Cms::BaseController
    def show
      @groups = Group.page params[:page]
      @setting = Setting.instance
    end
  end
end
