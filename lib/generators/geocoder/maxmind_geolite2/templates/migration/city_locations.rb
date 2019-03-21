class GeocoderMaxmindGeolite2CityLocations < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :maxmind_geolite2_city_locations_en, id: false do |t|
      t.integer :geoname_id, null: false
      t.string :locale_code, null: false, limit: 8
      t.string :continent_code, null: false, limit: 2
      t.string :continent_name, null: false
      t.string :country_iso_code, limit: 2
      t.string :country_name
      t.string :subdivision_1_iso_code, limit: 3
      t.string :subdivision_1_name
      t.string :subdivision_2_iso_code, limit: 3
      t.string :subdivision_2_name
      t.string :city_name
      t.integer :metro_code
      t.string :time_zone
      t.integer :is_in_european_union, null: false, limit: 1
    end

    add_index :maxmind_geolite2_city_locations_en, :geoname_id, unique: true
  end

  def self.down
    drop_table :maxmind_geolite2_city_locations_en
  end
end
