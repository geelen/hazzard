module Hazzard
  module Models
    class Library
      include Mongoid::Document

      field :name
      field :active, :type => Boolean
      field :imported_at, :type => Time
      field :duration, :type => Integer, :default => 0
      field :current_persistent_track_ids, :type => Array

    end
  end
end
