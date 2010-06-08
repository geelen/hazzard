module Hazzard
  module Models
    module Event
      class Base
        include Mongoid::Document

        field :description
      end

      class LibraryAppeared < Base
      end

      class LibraryDropped < Base
      end

      class LibraryImported < Base
        field :old_track_count, :type => Integer
        field :new_track_count, :type => Integer
      end

    end
  end
end
