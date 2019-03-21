class GeocoderMaxmindGeolite2CountryLocations < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :maxmind_geolite2_country_locations_en, id: false do |t|
      t.integer :geoname_id, null: false
      t.string :locale_code, null: false, limit: 8
      t.string :continent_code, null: false, limit: 2
      t.string :continent_name, null: false
      t.string :country_iso_code, limit: 2
      t.string :country_name
    end

    add_index :maxmind_geolite2_country_locations_en, :geoname_id, unique: true
  end

  def self.down
    drop_table :maxmind_geolite2_country_locations_en
  end
end
