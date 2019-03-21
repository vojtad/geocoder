require 'ipaddr'
require 'geocoder/lookups/base'
require 'geocoder/results/maxmind_geolite2_database'

module Geocoder::Lookup
  class MaxmindGeolite2Database < Base

    def name
      "MaxMind GeoLite2 Database"
    end

    def required_api_key_parts
      []
    end

    private

    def results(query)
      ip_address = IPAddr.new(query.text) rescue nil
      return [] if ip_address.nil?

      if configuration[:package] == :city
        q = "SELECT l.country_name, l.country_iso_code, l.subdivision_1_name, l.subdivision_1_iso_code, l.city_name, b.postal_code, b.latitude, b.longitude
        FROM maxmind_geolite2_city_locations_en l INNER JOIN #{blocks_table(ip_address)} b ON l.geoname_id = b.geoname_id
        WHERE b.network >>= inet '#{ip_address.to_s}'"
        format_result(q, [:country_name, :country_iso_code, :subdivision_1_name, :subdivision_1_iso_code, :city_name, :postal_code, :latitude, :longitude])
      elsif configuration[:package] == :country
        q = "SELECT l.country_name, l.country_iso_code
        FROM maxmind_geolite2_country_locations_en l INNER JOIN #{blocks_table(ip_address)} b ON l.geoname_id = b.geoname_id
        WHERE b.network >>= inet '#{ip_address.to_s}'"
        format_result(q, [:country_name, :country_iso_code, :latitude, :longitude])
      end
    end

    def format_result(query, attr_names)
      if r = ActiveRecord::Base.connection.execute(query).first
        r = r.values if r.is_a?(Hash) # some db adapters return Hash, some Array
        [Hash[*attr_names.zip(r).flatten]]
      else
        []
      end
    end

    def blocks_table(ip_address)
      ip_version_suffix = ip_address.ipv4? ? "ipv4" : "ipv6"
  
      case configuration[:package]
      when :city
        "maxmind_geolite2_city_blocks_#{ip_version_suffix}"
      when :country
        "maxmind_geolite2_country_blocks_#{ip_version_suffix}"
      end
    end
  end
end
