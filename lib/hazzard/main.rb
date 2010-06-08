require File.dirname(__FILE__) + '/all'

module Hazzard
  class Main
  end
  
  class << Main
    def import_all
      ITunes.instance.sources.each { |s| Models::Library.for(s) }
    end
  end
end
