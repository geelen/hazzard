module Hazzard
  class Main
    def self.import_all
      ITunes.instance.sources.each { |s| Models::Library.for(s) }
    end
  end
end
