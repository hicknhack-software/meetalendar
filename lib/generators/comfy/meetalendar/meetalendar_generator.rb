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
        migration_files = Dir.children(File.expand_path("../../../../db/migrate", __dir__)).select{|file_name| !file_name.starts_with?("00")}
        migration_files.each do |file|
          destination   = File.expand_path("db/migrate/#{file}", destination_root)
          migration_dir = File.dirname(destination)
          destination   = self.class.migration_exists?(migration_dir, file.sub(/\d\d_/, ''))

          if destination
            puts "\e[0m\e[31mFound existing #{file.sub(/\d\d_/, '')} migration. Remove it if you want to regenerate.\e[0m"
          else
            migration_template "db/migrate/#{file}", "db/migrate/#{file.sub(/\d\d_/, '')}"
          end
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
        directory "app/views/meetalendar", "app/views/meetalendar"
      end

      def show_readme
        readme "lib/generators/comfy/meetalendar/README"
      end
    end
  end
end
