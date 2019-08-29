# frozen_string_literal: true

require "rubygems"
require "rails"
require "comfortable_mexican_sofa"
require "meetalendar"

module Meetalendar

  module CmsSiteExtensions

    extend ActiveSupport::Concern
    included do
      has_many :meetalendar_meetups,
        class_name: "Meetalendar::Meetups",
        dependent:  :destroy
    end

  end

  class Engine < ::Rails::Engine

    initializer "meetalendar.configuration" do
      ComfortableMexicanSofa::ViewHooks.add(:navigation, "/comfy/admin/meetalendar/partials/navigation")
      config.to_prepare do
        Comfy::Cms::Site.send :include, Meetalendar::CmsSiteExtensions
      end
    end

  end

end
