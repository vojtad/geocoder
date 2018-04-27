class GeocoderMaxmindGeoliteCity < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :maxmind_geolite_city_blocks, id: false do |t|
      t.column :ip_range, :int8range, null: false
      t.column :loc_id, :bigint, null: false
    end
    add_index :maxmind_geolite_city_blocks, :loc_id
    add_index :maxming_geolite_city_with_range_blocks, :ip_range, using: 'gist', name: 'index_maxmind_geolite_city_blocks_on_ip_range'

    create_table :maxmind_geolite_city_location, id: false do |t|
      t.column :loc_id, :bigint, null: false
      t.string :country, null: false
      t.string :region, null: false
      t.string :city
      t.string :postal_code, null: false
      t.float :latitude
      t.float :longitude
      t.integer :metro_code
      t.integer :area_code
    end
    add_index :maxmind_geolite_city_location, :loc_id, unique: true
  end

  def self.down
    drop_table :maxmind_geolite_city_location
    drop_table :maxmind_geolite_city_blocks
  end
end
