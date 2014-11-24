#! /usr/bin/env ruby
#
# usage: from_scratch.rb
#
# This script shows you how to create a new sequence from scratch and save it
# to a MIDI file. It creates a file called 'from_scratch.mid'.

# Start looking for MIDI module classes in the directory above this one.
# This forces us to use the local copy, even if there is a previously
# installed version out there somewhere.
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')

require 'midilib/sequence'
require 'midilib/consts'
include MIDI

seq = Sequence.new()

# Create a first track for the sequence. This holds tempo events and stuff
# like that.
track = Track.new(seq)
seq.tracks << track
track.events << Tempo.new(Tempo.bpm_to_mpq(120))
track.events << MetaEvent.new(META_SEQ_NAME, 'Sequence Name')

# Create a track to hold the notes. Add it to the sequence.
track = Track.new(seq)
seq.tracks << track

# Give the track a name and an instrument name (optional).
track.name = 'My New Track'
track.instrument = GM_PATCH_NAMES[0]

# Add a volume controller event (optional).
track.events << Controller.new(0, CC_VOLUME, 127)

# Add events to the track: a major scale. Arguments for note on and note off
# constructors are channel, note, velocity, and delta_time. Channel numbers
# start at zero. We use the new Sequence#note_to_delta method to get the
# delta time length of a single quarter note.
track.events << ProgramChange.new(0, 1, 0)
quarter_note_length = seq.note_to_delta('quarter')
whole_note_length = seq.note_to_delta('whole')
note_length = seq.note_to_delta('eighth')
time = 0

def event(track, event, time)
  track.events << event
  event.time_from_start = time
end

def chord(track, time, note, note_length, harmony=[0, 4, 7, 9])
  harmony.each do |coff|
    event(track, NoteOn.new(0, note + coff, 127, 0), time)
  end

  time += note_length

  harmony.each do |coff|
    event(track, NoteOff.new(0, note + coff, 127, note_length), time)
  end

  time
end

note_length = quarter_note_length

=begin
event(track, NoteOn.new(0, 62, 127, 0), time)
time += note_length
event(track, NoteOff.new(0, 62, 127, note_length), time)

event(track, NoteOn.new(0, 60, 127, 0), time)
time += note_length
event(track, NoteOff.new(0, 60, 127, note_length), time)

event(track, NoteOn.new(0, 65, 127, 0), time)
time += note_length
event(track, NoteOff.new(0, 65, 127, note_length), time)

event(track, NoteOn.new(0, 64, 127, 0), time)
time += note_length
event(track, NoteOff.new(0, 64, 127, note_length), time)
=end

# time = chord(track, time, 62, note_length)
# time = chord(track, time, 60, note_length)
# time = chord(track, time, 65, note_length)
# time = chord(track, time, 64, note_length)

track.recalc_delta_from_times

=begin
=end

note_length = seq.note_to_delta('eighth')

chord_pattern = [0, 4, 7, 9]
chord_pattern = [0, 4, -5, 9]
chord_pattern = [0, 4, 7, -3]

# 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 
[60, 65, 58, 63, 56, 61, 54, 59, 64, 57, 62, 55, 60].each do |key|
# (60...73).each do |key|

# key = 60

[0, 2, 4, 5, 7, 9, 11, 12, 14, 12, 11, 9, 7, 5, 4, 2].each do |offset|

  chord_pattern.each do |coff|
    event(track, NoteOn.new(0, key + offset + coff, 127, 0), time)
  end

  time += note_length

  chord_pattern.each do |coff|
    event(track, NoteOff.new(0, key + offset + coff, 127, note_length), time)
  end

  # track.events << NoteOn.new(0, key + offset + 4, 127, 0)
  # track.events << NoteOff.new(0, key + offset + 4, 127, note_length)

  # track.events << NoteOn.new(0, key + offset + 10, 127, 0)
  # track.events << NoteOff.new(0, key + offset + 10, 127, note_length)

end

chord_pattern.each do |coff|
  event(track, NoteOn.new(0, key + coff, 127, 0), time)
end

time += whole_note_length

chord_pattern.each do |coff|
  event(track, NoteOff.new(0, key + coff, 127, whole_note_length), time)
end

track.recalc_delta_from_times

end


# Calling recalc_times is not necessary, because that only sets the events'
# start times, which are not written out to the MIDI file. The delta times are
# what get written out.

# track.recalc_times

File.open('from_scratch.mid', 'wb') { |file| seq.write(file) }
