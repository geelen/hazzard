class Library
  include Mongoid::Document

  field :persistent_id
  field :name
  field :active, :type => Boolean
  field :imported_at, :type => Time
  field :duration, :type => Integer, :default => 0
  field :current_persistent_track_ids, :type => Array

end
