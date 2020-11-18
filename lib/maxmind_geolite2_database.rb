require 'csv'
require 'net/http'

module Geocoder
  module MaxmindGeolite2Database
    extend self

    def download(package, dir = "tmp", download_url = nil)
      archive_url = download_url || archive_url(package)
      filepath = File.expand_path(File.join(dir, archive_filename(package)))
      print "Downloading #{archive_url} to #{filepath}..."
      open(filepath, 'wb') do |file|
        uri = URI.parse(archive_url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request_get(uri.request_uri) do |resp|
            resp.read_body do |segment|
              file.write(segment)
            end
          end
        end
      end
      puts " done."
    end

    def insert(package, dir = "tmp")
      data_files(package, dir).each do |filepath, table|
        print "Resetting table #{table}..."
        ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
        puts " done."
        insert_into_table(table, filepath)
      end
    end

    def update(package, dir = "tmp")
      updated_tables = []
      
      ActiveRecord::Base.transaction do
        data_files(package, dir).each do |filepath, table|
          update_table = "#{table}_update"
          print "Creating table #{update_table}..."
          ActiveRecord::Base.connection.execute("CREATE TABLE #{update_table} (LIKE #{table} INCLUDING ALL)")
          puts " done."
          insert_into_table(update_table, filepath)
          updated_tables << [update_table, table]
        end

        updated_tables.each do |tables|
          update_table, table = tables
          old_table = "#{table}_old"

          print "Replacing table #{table} with #{update_table}..."
          ActiveRecord::Base.connection.execute("ALTER TABLE #{table} RENAME TO #{old_table}")
          ActiveRecord::Base.connection.execute("ALTER TABLE #{update_table} RENAME TO #{table}")
          ActiveRecord::Base.connection.execute("DROP TABLE #{old_table}")
          puts " done."
        end
      end
    end

    def archive_filename(package)
      p = archive_url_path(package)
      s = !(pos = p.rindex('/')).nil? && pos + 1 || 0
      p[s..-1]
    end

    private # -------------------------------------------------------------

    def table_columns(table_name)
      real_table_name = table_name.gsub(/_update$/, '')

      {
        maxmind_geolite2_city_blocks_ipv4: %w[network geoname_id registered_country_geoname_id represented_country_geoname_id is_anonymous_proxy is_satellite_provider postal_code latitude longitude accuracy_radius],
        maxmind_geolite2_city_blocks_ipv6: %w[network geoname_id registered_country_geoname_id represented_country_geoname_id is_anonymous_proxy is_satellite_provider postal_code latitude longitude accuracy_radius],
        maxmind_geolite2_city_locations_en: %w[geoname_id locale_code continent_code continent_name country_iso_code country_name subdivision_1_iso_code subdivision_1_name subdivision_2_iso_code subdivision_2_name city_name metro_code time_zone is_in_european_union],
        maxmind_geolite2_country_blocks_ipv4: %w[],
        maxmind_geolite2_country_blocks_ipv6: %w[],
        maxmind_geolite2_country_locations_en: %w[geoname_id locale_code continent_code continent_name country_iso_code country_name subdivision_1_iso_code subdivision_1_name subdivision_2_iso_code subdivision_2_name city_name metro_code time_zone is_in_european_union],
      }[real_table_name.to_sym]
    end

    def insert_into_table(table, filepath)
      start_time = Time.now
      print "Inserting data from #{filepath} into table #{table}..."
      rows = []
      columns = table_columns(table)
      CSV.foreach(filepath, encoding: "ISO-8859-1") do |line|
        # Some files have header rows.
        # skip if starts with "Copyright" or "locId" or "startIpNum"
        next if line.first.match(/[A-z]/)
        rows << line.to_a
        if rows.size == 10000
          insert_rows(table, columns, rows)
          rows = []
          print "."
        end
      end
      insert_rows(table, columns, rows) if rows.size > 0
      puts " done (#{Time.now - start_time} seconds)."
    end

    def insert_rows(table, headers, rows)
      value_strings = rows.map do |row|
        "(" + row.map{ |col| sql_escaped_value(col) }.join(',') + ")"
      end
      q = "INSERT INTO #{table} (#{headers.join(',')}) " +
        "VALUES #{value_strings.join(',')}"
      ActiveRecord::Base.connection.execute(q)
    end

    def sql_escaped_value(value)
      value.to_i.to_s == value ? value :
        ActiveRecord::Base.connection.quote(value)
    end

    def data_dir(package, dir)
      subdir = case package
        when :geolite2_city_csv
          'GeoLite2-City-CSV_*'
        when :geolite2_country_csv
          'GeoLite2-Country-CSV_*'
      end

      dirs = Dir.glob(File.join(dir, subdir)).sort
      dirs.last
    end

    def data_files(package, dir = "tmp")
      case package
      when :geolite2_city_csv
        {
          File.join(data_dir(package, dir), "GeoLite2-City-Blocks-IPv4.csv") => "maxmind_geolite2_city_blocks_ipv4",
          File.join(data_dir(package, dir), "GeoLite2-City-Blocks-IPv6.csv") => "maxmind_geolite2_city_blocks_ipv6",
          File.join(data_dir(package, dir), "GeoLite2-City-Locations-en.csv") => "maxmind_geolite2_city_locations_en"
        }
      when :geolite2_country_csv
        {
          File.join(data_dir(package, dir), "GeoLite2-Country-Blocks-IPv4.csv") => "maxmind_geolite2_country_blocks_ipv4",
          File.join(data_dir(package, dir), "GeoLite2-Country-Blocks-IPv6.csv") => "maxmind_geolite2_country_blocks_ipv6",
          File.join(data_dir(package, dir), "GeoLite2-Country-Locations-en.csv") => "maxmind_geolite2_country_locations_en"
        }
      end
    end

    def archive_url(package)
      base_url + archive_url_path(package)
    end

    def archive_url_path(package)
      {
        geolite2_country_csv: "GeoLite2-Country-CSV.zip",
        geolite2_city_csv: "GeoLite2-City-CSV.zip",
        geolite2_asn_csv: "GeoLite2-ASN-CSV.zip"
      }[package]
    end

    def base_url
      "http://geolite.maxmind.com/download/geoip/database/"
    end
  end
end
