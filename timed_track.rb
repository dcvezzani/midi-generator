class TimedTrack < MIDI::Track
  MIDDLE_C = 60
  @@channel_counter=0

  def initialize(number, song)
    super(number)
    @sequence = song
    @time = 0
    @channel = @@channel_counter
    @@channel_counter += 1
  end

  # Tell this track's channel to use the given instrument, and
  # also set the track's instrument display name.
  def instrument=(instrument)
    @events <<  
MIDI::ProgramChange.new(@channel, instrument)
    super(MIDI::GM_PATCH_NAMES[instrument])
  end

  # Add one or more notes to sound simultaneously. Increments the per-track
  # timer so that subsequent notes will sound after this one finishes.
  def add_notes(offsets, velocity=127, duration='quarter')
    offsets = [offsets] unless offsets.respond_to? :each
    offsets.each do |offset|
      event(MIDI::NoteOnEvent.new(@channel, MIDDLE_C + offset, velocity))
    end
    @time += @sequence.note_to_delta(duration)
    offsets.each do |offset|
      event(MIDI::NoteOffEvent.new(@channel, MIDDLE_C + offset, velocity))
    end
    recalc_delta_from_times
  end

  # Uses add_notes to sound a chord (a major triad in root position), using the
  # given note as the low note. Like add_notes, increments the per-track timer.
  def add_major_triad(low_note, velocity=127, duration='quarter')
    add_notes([0, 4, 7].collect { |x| x + low_note }, velocity, duration)
  end

  private

  def event(event)
    @events << event
   event.time_from_start = @time
  end
end
