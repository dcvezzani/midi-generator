$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')

require 'midilib/sequence'
require 'midilib/consts'
require './midi_array'
require './timed_track'
include MIDI

song = MIDI::Sequence.new
song.tracks << (melody = TimedTrack.new(0, song))
song.tracks << (background = TimedTrack.new(1, song))

melody.instrument = 56 # Trumpet
background.instrument = 19 # Church organ

melody.events << MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(120))
melody.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME,
                                    'A random Ruby composition')

# Some musically pleasing intervals: thirds and fifths.
intervals = [-5, -1, 0, 4, 7]

# Start at middle C.
note = 0
# Create 8 measures of music in 4/4 time
(8*4).times do |i|
  note += intervals[rand(intervals.size)]

  #Reset to middle C if we go out of the MIDI range
  note = 0 if note < -39 or note > 48

  # Add a quarter note on every beat.
  melody.add_notes(note, 127, 'quarter')

  # Add a chord of whole notes at the beginning of each measure.
  background.add_major_triad(note, 50, 'whole') if i % 4 == 0
end

open('random.mid', 'w') { |f| song.write(f) }
=begin
=end

