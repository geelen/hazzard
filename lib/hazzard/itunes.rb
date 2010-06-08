module Hazzard
  class ITunes
    include Singleton

    def sources
      app.sources.get.select {|s|
        [:library, :shared_library].include? s.kind.get
      }
    end

    def player_state
      app.player_state.get
    end

    def stopped?
      :stopped == player_state
    end

    def playing?
      :playing == player_state
    end

    def paused?
      :paused  == player_state
    end

    def play! obj = nil
      if obj
        app.play obj, :once => true, :timeout => 5
      elsif paused?
        app.playpause
      end
    end

    def pause!
      app.pause
    end

    def stop!
      app.stop
    end

    private

    def app
      require 'appscript'
      @app ||= Appscript::app('iTunes')
    end
  end
end
