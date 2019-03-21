require 'geocoder/results/base'

module Geocoder::Result
  class MaxmindGeolite2Database < Base

    def coordinates
      [@data[:latitude], @data[:longitude]]
    end

    def city
      @data[:city_name]
    end

    def state
      @data[:subdivision_1_name]
    end

    def state_code
      @data[:subdivision_1_iso_code]
    end

    def country
      @data[:country_name]
    end

    def country_code
      @data[:country_iso_code]
    end

    def postal_code
      @data[:postal_code]
    end

    def self.response_attributes
      %w[ip]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
