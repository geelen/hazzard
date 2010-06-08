require 'mongoid'

Mongoid::Config.instance.from_hash({'database' => 'hazzard'})

Dir.glob("#{File.dirname(__FILE__)}/hazzard/models/*.rb").each { |f| require f }

module Hazzard
  def self.load_all!
    require File.dirname(__FILE__) + '/hazzard/itunes'
    Dir.glob("#{File.dirname(__FILE__)}/hazzard/models/write/*.rb").each { |f| require f }
  end

  def self.main
    load_all!
    require File.dirname(__FILE__) + '/hazzard/main'
    Main
  end
end
