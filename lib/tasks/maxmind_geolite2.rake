require 'maxmind_geolite2_database'

namespace :geocoder do
  namespace :maxmind_geolite2 do
    desc "Download and load/refresh MaxMind GeoLite2 City data"
    task load: [:download, :extract, :insert]

    desc "Download and update MaxMind GeoLite2 City data using temporary tables"
    task update: [:download, :extract, :update_tables]

    desc "Download MaxMind GeoLite 2 City data"
    task :download do
      p = MaxmindGeolite2Task.check_for_package!
      MaxmindGeolite2Task.download!(p, dir: ENV['DIR'] || "tmp/", download_url: ENV['DOWNLOAD_URL'])
    end

    desc "Extract (unzip) MaxMind GeoLite 2 City data"
    task :extract do
      p = MaxmindGeolite2Task.check_for_package!
      MaxmindGeolite2Task.extract!(p, dir: ENV['DIR'] || "tmp/")
    end

    desc "Load/refresh MaxMind GeoLite 2 City data"
    task insert: [:environment] do
      p = MaxmindGeolite2Task.check_for_package!
      MaxmindGeolite2Task.insert!(p, dir: ENV['DIR'] || "tmp/")
    end

    desc "Update MaxMind GeoLite 2 City data using temporary update table"
    task update_tables: [:environment] do
      p = MaxmindGeolite2Task.check_for_package!
      MaxmindGeolite2Task.update!(p, dir: ENV['DIR'] || "tmp/")
    end
  end
end

module MaxmindGeolite2Task
  extend self

  def check_for_package!
    if %w[city country].include?(p = ENV['PACKAGE'])
      return p
    else
      puts "Please specify PACKAGE=city or PACKAGE=country"
      exit
    end
  end

  def download!(package, options = {})
    Geocoder::MaxmindGeolite2Database.download(full_pacage_name(package), options[:dir], options[:download_url])
  end

  def extract!(package, options = {})
    begin
      require 'zip'
    rescue LoadError
      puts "Please install gem: rubyzip (>= 1.0.0)"
      exit
    end
    require 'fileutils'
    archive_filename = Geocoder::MaxmindGeolite2Database.archive_filename(full_pacage_name(package))
    puts "Extracting #{archive_filename}..."
    Zip::File.open(File.join(options[:dir], archive_filename)).each do |entry|
      filepath = File.join(options[:dir], entry.name)
      puts "Extracting #{entry.name}..."
      if File.exist? filepath
        warn "File already exists (#{entry.name}), skipping"
      else
        FileUtils.mkdir_p(File.dirname(filepath))
        entry.extract(filepath)
      end
    end
  end

  def insert!(package, options = {})
    Geocoder::MaxmindGeolite2Database.insert(full_pacage_name(package), options[:dir])
  end

  def update!(package, options = {})
    Geocoder::MaxmindGeolite2Database.update(full_pacage_name(package), options[:dir])
  end

  private

  def full_pacage_name(package)
    "geolite2_#{package}_csv".intern
  end
end
