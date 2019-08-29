# frozen_string_literal: true

require "rails/generators/active_record"

module Comfy
  module Generators
    class MeetalendarGenerator < Rails::Generators::Base

      include Rails::Generators::Migration
      include Thor::Actions

      source_root File.expand_path("../../../..", __dir__)

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def generate_migration
        destination   = File.expand_path("db/migrate/01_create_meetalendar_meetup_groups.rb", destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, "create_meetalendar_meetup_groups")

        if destination
          puts "\e[0m\e[31mFound existing create_meetalendar_meetup_groups migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template "db/migrate/01_create_meetalendar_meetup_groups.rb", "db/migrate/create_meetalendar_meetup_groups.rb"
        end

        destination   = File.expand_path("db/migrate/02_create_meetalendar_auth_credentials.rb", destination_root)
        migration_dir = File.dirname(destination)
        destination   = self.class.migration_exists?(migration_dir, "create_meetalendar_auth_credentials.rb")

        if destination
          puts "\e[0m\e[31mFound existing create_meetalendar_auth_credentials migration. Remove it if you want to regenerate.\e[0m"
        else
          migration_template "db/migrate/02_create_meetalendar_auth_credentials.rb", "db/migrate/create_meetalendar_auth_credentials.rb"
        end
      end

      def generate_initialization
        copy_file "config/initializers/meetalendar.rb",
          "config/initializers/meetalendar.rb"
      end

      def generate_routing
        route_string = <<-RUBY.strip_heredoc
          comfy_route :meetalendar_admin, path: "/admin"
        RUBY
        route route_string
      end

      def generate_views
        directory "app/views/comfy/admin/meetalendar", "app/views/comfy/admin/meetalendar"
      end

      def show_readme
        readme "lib/generators/comfy/meetalendar/README"
      end
    end
  end
end
