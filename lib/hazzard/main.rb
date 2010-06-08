module Hazzard
  class Main
    def self.import_all
      (Models::Library.all | ITunes.instance.sources.map {|source|
        Models::Library.for source
      }).each &:import!
    end
  end
end
