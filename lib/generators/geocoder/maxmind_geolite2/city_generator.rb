require 'rails/generators/migration'
require 'generators/geocoder/migration_version'

module Geocoder
  module Generators
    module MaxmindGeolite2
      class CityGenerator < Rails::Generators::Base
        include Rails::Generators::Migration
        include Generators::MigrationVersion

        source_root File.expand_path('../templates', __FILE__)

        def copy_migration_files
          migration_template "migration/city_blocks.rb", "db/migrate/geocoder_maxmind_geolite2_city_blocks.rb"
          migration_template "migration/city_locations.rb", "db/migrate/geocoder_maxmind_geolite2_city_locations.rb"
        end

        # Define the next_migration_number method (necessary for the
        # migration_template method to work)
        def self.next_migration_number(dirname)
          if ActiveRecord::Base.timestamped_migrations
            sleep 1 # make sure each time we get a different timestamp
            Time.new.utc.strftime("%Y%m%d%H%M%S")
          else
            "%.3d" % (current_migration_number(dirname) + 1)
          end
        end
      end
    end
  end
end
