# frozen_string_literal: true

require "rubygems"
require "rails"
require "comfortable_mexican_sofa"
require "meetalendar"

module Meetalendar
  class Engine < ::Rails::Engine

    initializer "meetalendar.configuration" do
      ComfortableMexicanSofa::ViewHooks.add(:navigation, "/comfy/admin/meetalendar/partials/navigation")
    end

  end
end
