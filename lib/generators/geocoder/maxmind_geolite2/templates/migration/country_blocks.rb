class GeocoderMaxmindGeolite2CountryBlocks < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :maxmind_geolite2_country_blocks_ipv4, id: false do |t|
      t.cidr :network, null: false
      t.integer :geoname_id
      t.integer :registered_country_geoname_id
      t.integer :represented_country_geoname_id
      t.integer :is_anonymous_proxy, null: false, limit: 1
      t.integer :is_satellite_provider, null: false, limit: 1
    end

    add_index :maxmind_geolite2_country_blocks_ipv4, :geoname_id
    add_index :maxmind_geolite2_country_blocks_ipv4, 'network inet_ops', using: :gist

    create_table :maxmind_geolite2_country_blocks_ipv6, id: false do |t|
      t.cidr :network, null: false
      t.integer :geoname_id
      t.integer :registered_country_geoname_id
      t.integer :represented_country_geoname_id
      t.integer :is_anonymous_proxy, null: false, limit: 1
      t.integer :is_satellite_provider, null: false, limit: 1
    end

    add_index :maxmind_geolite2_country_blocks_ipv6, :geoname_id
    add_index :maxmind_geolite2_country_blocks_ipv6, 'network inet_ops', using: :gist
  end

  def self.down
    drop_table :maxmind_geolite2_country_blocks_ipv4
    drop_table :maxmind_geolite2_country_blocks_ipv6
  end
end
