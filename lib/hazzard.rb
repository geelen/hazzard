require 'rubygems'
require 'mongoid'

Mongoid::Config.instance.from_hash({'database' => 'hazzard'})

require File.dirname(__FILE__) + '/hazzard/library.rb'
