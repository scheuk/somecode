module Kitchen
  module Driver
    # Version string for OpenStack Kitchen driver
    FTA_VERSION = File.open("#{File.dirname(__FILE__)}/../../../VERSION"){|f| f.readline}.strip
  end
end