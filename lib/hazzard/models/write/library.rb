module Hazzard
  module Models
    class Library
      def self.for(source)
        find_or_create_by(:name => source.name.get)
      end

      def source
        Hazzard::ITunes.instance.sources.
          select {|s| s.name.get == name }.
          map { |s| s.library_playlists.first}.
          first
      end

      def import!
        if source.nil?
          if active?
            Event::LibraryDropped.create! :description => "#{name} just went offline"
            update_attributes! :active => false
          end
        else
          source_duration = source.duration.get || 0
          if source_duration > 0 #source duration is 0 while the library is being connected
            update_attributes :active => true

            if duration == source_duration
              # puts "Track count for #{name} hasn't changed, skipping."
            else
              if duration.zero?
                Event::LibraryAppeared.create! :description => "Hello #{name}! Importing now - each track is playable as soon as it's imported."
              else
                duration_delta = source_duration - duration
                Event::LibraryAppeared.create! :description => "Hey, #{name} #{duration_delta < 0 ? 'shrank' : 'grew'} by #{duration_delta.abs.xsecs} - importing the difference."
              end
              
              import_tracks!
              update_attributes :duration => source_duration
            end
          end
        end
      end

      def source_tracks
        if @source_tracks.nil?
          gt = Time.now
          puts "Loading source tracks into memory."
          @source_tracks = Hash.new { |h, k| h[k] = [] }
          cols = %w[persistent_ID enabled podcast video_kind artist album name year duration track_number track_count disc_number disc_count bit_rate kind]
          col_data = cols.map { |c| source.tracks.send(c.to_sym).get }
          puts "Applescript done (#{Time.now - gt} seconds). Everything in memory now, hashifying."
          col_data.transpose.each { |row|
            t = Hash[*cols.zip(row).flatten]
            @source_tracks[t['persistent_ID']] = t if t['enabled'] && !t['podcast'] && t['video_kind'] == :none
          }
          puts "Done (total #{Time.now - gt} seconds)."
        end
        @source_tracks
      end

      private

      def import_tracks!
        want = source_tracks.keys
        current_persistent_track_ids ||= []
        have_and_dont_want, want_and_dont_have = current_persistent_track_ids - want, want - current_persistent_track_ids

        if have_and_dont_want.empty? && want_and_dont_have.empty?
          puts "Nothing to update for #{name}."
        else
          original_track_count = current_persistent_track_ids.length

          puts "This library contains #{original_track_count - current_persistent_track_ids.length} dirty track#{'s' unless original_track_count - current_persistent_track_ids.length == 1} that will be re-imported." unless original_track_count == current_persistent_track_ids.length

          have_and_dont_want.each {|old_id|
            old_track = tracks.find_by_persistent_id(old_id)
            puts "Track #{old_track.library.name}/#{old_track.persistent_id}: #{old_track.name} disappeared, removing."
            old_track.destroy
          }
          want_and_dont_have.each {|new_id|
            puts "Would have imported: #{source_tracks[new_id].inspect}"
#            Track.import! source_tracks[new_id], self
          }

          current_persistent_track_ids = want
          save!

          update_attributes :imported_at => Time.now
          puts "Finished importing #{name} - library went from #{original_track_count} to #{current_persistent_track_ids.count} tracks (#{want_and_dont_have.length} added, #{have_and_dont_want.length} removed).\n"

          Event::LibraryImported.create! :description => "Finished importing #{name}",
                                         :old_track_count => original_track_count,
                                         :new_track_count => current_persistent_track_ids.count
        end
      end
    end
  end
end
