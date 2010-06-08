require 'mongoid'

Mongoid::Config.instance.from_hash({'database' => 'hazzard'})

Dir.glob("#{File.dirname(__FILE__)}/models/*.rb").each { |f| require f }
