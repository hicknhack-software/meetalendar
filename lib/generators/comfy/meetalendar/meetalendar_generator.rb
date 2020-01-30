# frozen_string_literal: true

require "rails/generators/active_record"

module Comfy
  module Generators
    class MeetalendarGenerator < Rails::Generators::Base

      include ActiveRecord::Generators::Migration

      source_root File.expand_path("../../../..", __dir__)

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def generate_migration
        migration_source_dir = File.expand_path('db/migrate', self.class.source_root)
        migration_dest_dir = File.expand_path(db_migrate_path, destination_root)
        self.class.migration_lookup_at(migration_source_dir).each do |filepath|
          filename = filepath.sub /^.+\/(.+\.rb)$/, '\1'
          migration = filename.sub /^\d+_(.+)\.rb$/, '\1'
          if self.class.migration_exists?(migration_dest_dir, migration)
            puts "\e[0m\e[31mFound existing #{migration} migration. Remove it if you want to regenerate.\e[0m"
          else
            migration_template "db/migrate/#{filename}", "#{db_migrate_path}/#{migration}.rb"
          end
        end
      end

      def generate_initialization
      end

      def generate_routing
        route_string = <<-RUBY.strip_heredoc
          comfy_route :meetalendar_admin, path: "/admin"
        RUBY
        route route_string
      end

      def generate_views
      end

      def show_readme
        readme "lib/generators/comfy/meetalendar/README"
      end
    end
  end
end
