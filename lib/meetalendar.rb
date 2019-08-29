# frozen_string_literal: true

require_relative "meetalendar/version"
require_relative "meetalendar/engine"
require_relative "meetalendar/configuration"
require_relative "meetalendar/routing"

module Meetalendar

  class << self

    # Modify Blog configuration
    # Example:
    #   Meetalendar.configure do |config|
    #     config.posts_per_page = 5
    #   end
    def configure
      yield configuration
    end

    # Accessor for Meetalendar::Configuration
    def configuration
      @configuration ||= Meetalendar::Configuration.new
    end
    alias config configuration

  end

end
