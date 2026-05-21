extends Node

signal beat_hit(type)

const SILENCE_NOTE = -99
const DEFAULT_STAGE_ID = "menu"
const AUDIO_CHUNKS_PER_SECOND = 60.0

var player: AudioStreamPlayer = null
var playback: AudioStreamGeneratorPlayback = null
var generator: AudioStreamGenerator = null
var audio_thread: Thread = null
var audio_mutex = Mutex.new()
var thread_active = false
var chunk_frame_count = 735
var _target_volume = 0.55
var _pending_stage_id = DEFAULT_STAGE_ID
var _state_dirty = true

var sample_rate = 44100.0
var phase_lead = 0.0
var phase_bass = 0.0
var phase_hat = 0.0
var phase_harmony = 0.0
var phase_pad = 0.0
var sample_clock = 0
var music_volume = 0.55
var stage_id = "menu"
var rng = RandomNumberGenerator.new()
var last_step_tick = -1
var lead_freq_current = 440.0
var lead_level = 0.0
var harmony_freq_current = 330.0
var harmony_level = 0.0
var bass_freq_current = 110.0
var string_voices = []
var current_melody_note: int = 0

var stage_profiles = {
	"menu": {
		"bpm": 92.0,
		"root": 110.0,
		"melody_start": 0,
		"melody_markov": {
			0: {SILENCE_NOTE: 20},
			3: {SILENCE_NOTE: 10, 0: 10},
			5: {SILENCE_NOTE: 10, 7: 10},
			7: {SILENCE_NOTE: 20, 10: 10},
			10: {7: 10},
			SILENCE_NOTE: {0: 10, 3: 20, 5: 20, 7: 10}
		},
		"chords": [[0, 3, 7], [5, 8, 12], [3, 7, 10], [0, 3, 7]],
		"bass": [0, 0, 5, 3],
		"lead_gain": 0.13,
		"harmony_gain": 0.035,
		"bass_gain": 0.10,
		"pad_gain": 0.025,
		"kick_gain": 0.055,
		"snare_gain": 0.018,
		"hat_gain": 0.025,
		"lead_decay": 0.72,
		"wave": "triangle"
	},
	"ghost_town": {
		"bpm": 118.0,
		"root": 110.0,
		"melody_start": 0,
		"melody_markov": {
			-12: {SILENCE_NOTE: 10},
			0: {SILENCE_NOTE: 20, 3: 10},
			3: {SILENCE_NOTE: 10, 0: 20, 5: 20},
			5: {SILENCE_NOTE: 10, 3: 30, 7: 20},
			7: {SILENCE_NOTE: 10, 5: 30, 10: 20},
			10: {7: 30, 12: 10},
			12: {10: 10},
			SILENCE_NOTE: {-12: 10, 0: 10, 3: 10, 5: 10, 7: 10, 10: 10}
		},
		"chords": [[0, 3, 7], [5, 8, 12], [7, 10, 14], [3, 7, 10]],
		"bass": [0, 0, 5, 7, 3, 3, 5, 7],
		"lead_gain": 0.16,
		"harmony_gain": 0.052,
		"bass_gain": 0.13,
		"pad_gain": 0.035,
		"kick_gain": 0.10,
		"snare_gain": 0.036,
		"hat_gain": 0.044,
		"lead_decay": 0.60,
		"wave": "triangle"
	},
	"canyon": {
		"bpm": 132.0,
		"root": 123.47,
		"melody_start": 7,
		"melody_markov": {
			-2: {0: 10},
			0: {SILENCE_NOTE: 10, -2: 10, 2: 10, 3: 10},
			2: {SILENCE_NOTE: 10, 0: 20, 3: 20},
			3: {SILENCE_NOTE: 10, 2: 20, 7: 30},
			7: {3: 30, 7: 10, 9: 20, 10: 10},
			9: {7: 30, 12: 10},
			10: {9: 10},
			12: {9: 10},
			SILENCE_NOTE: {0: 10, 2: 20}
		},
		"chords": [[0, 3, 7], [2, 5, 9], [3, 7, 10], [-2, 2, 7]],
		"bass": [0, 7, 0, 2, 3, 10, 7, 2],
		"lead_gain": 0.17,
		"harmony_gain": 0.045,
		"bass_gain": 0.12,
		"pad_gain": 0.022,
		"kick_gain": 0.088,
		"snare_gain": 0.030,
		"hat_gain": 0.062,
		"lead_decay": 0.48,
		"wave": "saw"
	},
	"broken_fort": {
		"bpm": 108.0,
		"root": 103.83,
		"melody_start": 0,
		"melody_markov": {
			-2: {0: 10},
			0: {SILENCE_NOTE: 40, 3: 10},
			3: {SILENCE_NOTE: 20, 0: 20},
			5: {3: 30, 6: 20},
			6: {5: 30, 10: 10},
			7: {6: 20},
			10: {SILENCE_NOTE: 10, 7: 20},
			12: {10: 10},
			SILENCE_NOTE: {-2: 10, 0: 20, 5: 20, 10: 10, 12: 10}
		},
		"chords": [[0, 3, 7], [5, 8, 12], [6, 10, 13], [3, 7, 10]],
		"bass": [0, 0, 6, 5, 3, 3, 5, 6],
		"lead_gain": 0.15,
		"harmony_gain": 0.058,
		"bass_gain": 0.16,
		"pad_gain": 0.038,
		"kick_gain": 0.12,
		"snare_gain": 0.052,
		"hat_gain": 0.032,
		"lead_decay": 0.66,
		"wave": "square"
	},
	"mine": {
		"bpm": 96.0,
		"root": 98.0,
		"melody_start": 0,
		"melody_markov": {
			-4: {SILENCE_NOTE: 10, 0: 10},
			0: {SILENCE_NOTE: 40, 2: 10},
			2: {SILENCE_NOTE: 10, 0: 10, 5: 20},
			5: {SILENCE_NOTE: 20, 2: 20, 8: 20},
			7: {5: 30},
			8: {SILENCE_NOTE: 10, 7: 20},
			SILENCE_NOTE: {-4: 20, 0: 30, 2: 10, 5: 10, 7: 10, 8: 10}
		},
		"chords": [[0, 2, 7], [-4, 0, 5], [5, 8, 12], [2, 5, 8]],
		"bass": [0, -12, -4, -4, 5, 5, 2, -4],
		"lead_gain": 0.14,
		"harmony_gain": 0.050,
		"bass_gain": 0.17,
		"pad_gain": 0.055,
		"kick_gain": 0.095,
		"snare_gain": 0.025,
		"hat_gain": 0.024,
		"lead_decay": 0.84,
		"wave": "sine"
	},
	"bonus": {
		"bpm": 140.0,
		"root": 123.47,
		"melody_start": 10,
		"melody_markov": {
			0: {SILENCE_NOTE: 10, 2: 10},
			2: {0: 20, 4: 10, 7: 10},
			4: {2: 30, 7: 10},
			7: {4: 30, 10: 30},
			10: {7: 30, 10: 10, 12: 20, 14: 10},
			12: {10: 30, 14: 10},
			14: {12: 20, 17: 10},
			17: {14: 10},
			SILENCE_NOTE: {7: 10}
		},
		"chords": [[0, 4, 7], [2, 7, 10], [4, 7, 12], [7, 10, 14]],
		"bass": [0, 7, 2, 7, 4, 10, 7, 14],
		"lead_gain": 0.18,
		"harmony_gain": 0.070,
		"bass_gain": 0.14,
		"pad_gain": 0.042,
		"kick_gain": 0.12,
		"snare_gain": 0.045,
		"hat_gain": 0.064,
		"lead_decay": 0.42,
		"wave": "saw"
	}
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		return

	rng.randomize()
	chunk_frame_count = maxi(1, int(sample_rate / AUDIO_CHUNKS_PER_SECOND))
	generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.18
	player = AudioStreamPlayer.new()
	player.stream = generator
	add_child(player)
	player.play()
	playback = player.get_stream_playback()
	thread_active = true
	audio_thread = Thread.new()
	audio_thread.start(Callable(self, "_audio_thread_loop"))

func _exit_tree():
	audio_mutex.lock()
	thread_active = false
	audio_mutex.unlock()

	if audio_thread != null and audio_thread.is_started():
		audio_thread.wait_to_finish()
	audio_thread = null

	if player != null:
		player.stop()
	playback = null
	player = null
	generator = null

func configure(new_stage_id):
	audio_mutex.lock()
	_pending_stage_id = new_stage_id if stage_profiles.has(new_stage_id) else DEFAULT_STAGE_ID
	_state_dirty = true
	audio_mutex.unlock()

	if audio_thread == null or not audio_thread.is_started():
		_apply_pending_audio_state(_pending_stage_id, true, _target_volume)

func set_music_volume(value):
	audio_mutex.lock()
	_target_volume = clampf(value, 0.0, 1.0)
	audio_mutex.unlock()

	if audio_thread == null or not audio_thread.is_started():
		music_volume = _target_volume

func _audio_thread_loop():
	while true:
		audio_mutex.lock()
		var should_continue = thread_active
		var next_stage_id = _pending_stage_id
		var next_volume = _target_volume
		var should_reset_state = _state_dirty
		_state_dirty = false
		audio_mutex.unlock()

		if not should_continue:
			break

		_apply_pending_audio_state(next_stage_id, should_reset_state, next_volume)

		if playback == null:
			OS.delay_msec(1)
			continue

		if playback.get_frames_available() < chunk_frame_count:
			OS.delay_msec(1)
			continue

		var chunk = PackedVector2Array()
		chunk.resize(chunk_frame_count)

		for i in range(chunk_frame_count):
			chunk[i] = _next_frame()

		playback.push_buffer(chunk)

func _apply_pending_audio_state(new_stage_id, should_reset_state, new_volume):
	music_volume = clampf(float(new_volume), 0.0, 1.0)
	if not should_reset_state:
		return

	stage_id = new_stage_id if stage_profiles.has(new_stage_id) else DEFAULT_STAGE_ID
	_reset_music_state(stage_profiles.get(stage_id, stage_profiles[DEFAULT_STAGE_ID]))

func _reset_music_state(profile):
	sample_clock = 0
	phase_lead = 0.0
	phase_bass = 0.0
	phase_hat = 0.0
	phase_harmony = 0.0
	phase_pad = 0.0
	last_step_tick = -1
	lead_level = 0.0
	harmony_level = 0.0
	lead_freq_current = 440.0
	harmony_freq_current = 330.0
	bass_freq_current = 110.0
	current_melody_note = int(profile.get("melody_start", 0))
	string_voices.clear()

func _next_frame():
	var profile = stage_profiles.get(stage_id, stage_profiles[DEFAULT_STAGE_ID])
	var bpm = float(profile.get("bpm", 110.0))
	var root = float(profile.get("root", 110.0))
	var samples_per_step = sample_rate * 60.0 / bpm / 2.0
	var step_tick = int(float(sample_clock) / samples_per_step)
	var step_pos = fmod(float(sample_clock), samples_per_step) / samples_per_step
	var step = step_tick % 32
	var phrase = int(step_tick / 32)
	var melody_markov = profile.get("melody_markov", stage_profiles[DEFAULT_STAGE_ID]["melody_markov"])
	var chords = profile.get("chords", stage_profiles[DEFAULT_STAGE_ID]["chords"])
	var bass_line = profile.get("bass", stage_profiles[DEFAULT_STAGE_ID]["bass"])
	var chord = chords[int(step_tick / 8) % chords.size()]
	_trigger_step(profile, root, step_tick, step, phrase, melody_markov, chords, bass_line)

	var pad_freq = _note_freq(root * 0.5, int(chord[0]))
	var vibrato = 1.0 + sin(float(sample_clock) / sample_rate * TAU * 5.4) * 0.006
	phase_lead = fmod(phase_lead + lead_freq_current * vibrato / sample_rate, 1.0)
	phase_harmony = fmod(phase_harmony + harmony_freq_current / sample_rate, 1.0)
	phase_bass = fmod(phase_bass + bass_freq_current / sample_rate, 1.0)
	phase_pad = fmod(phase_pad + pad_freq / sample_rate, 1.0)
	phase_hat = fmod(phase_hat + 7600.0 / sample_rate, 1.0)

	var string_sample = _process_string_voices()
	var lead = _harmonica(phase_lead) * lead_level * float(profile.get("lead_gain", 0.15)) * 0.80
	var harmony = _harmonica(phase_harmony) * harmony_level * float(profile.get("harmony_gain", 0.05)) * 0.45
	var bass = _sine(phase_bass) * lead_level * float(profile.get("bass_gain", 0.13)) * 0.08
	var pad = _sine(phase_pad) * (0.7 + sin(float(sample_clock) / sample_rate * TAU * 0.23) * 0.3) * float(profile.get("pad_gain", 0.03))
	var kick = _kick(step, step_pos, float(profile.get("kick_gain", 0.10)))
	var snare = _snare(step, step_pos, float(profile.get("snare_gain", 0.03)))
	var hat = _hat(step, step_pos, float(profile.get("hat_gain", 0.04)))
	lead_level *= 0.99955
	harmony_level *= 0.99935
	var sample = string_sample + lead + harmony + bass + pad + kick + snare + hat
	sample *= music_volume
	sample_clock += 1
	return Vector2(sample, sample)

func _trigger_step(profile, root, step_tick, step, phrase, melody_markov, chords, bass_line):
	if step_tick == last_step_tick:
		return
	last_step_tick = step_tick

	var melody_note = SILENCE_NOTE
	if step % 2 == 0:
		current_melody_note = _get_next_markov_note(current_melody_note, melody_markov)
		melody_note = current_melody_note

	var chord = chords[int(step_tick / 8) % chords.size()]
	var harmony_note = int(chord[(int(step_tick / 4) + phrase) % chord.size()])
	var bass_note = int(bass_line[int(step_tick / 4) % bass_line.size()])
	var is_kick = step % 8 == 0 or (stage_id == "canyon" and step % 16 == 12) or (stage_id == "bonus" and step % 8 == 6)
	var is_snare = step % 16 == 8 or step % 16 == 14
	if stage_id == "mine":
		is_snare = step % 16 == 12

	if is_kick:
		_emit_beat_hit("kick")
	elif is_snare:
		_emit_beat_hit("snare")

	if melody_note > -90:
		lead_freq_current = _note_freq(root * 2.0, melody_note)
		lead_level = 1.0
		if step % 4 == 2:
			_pluck_string(lead_freq_current, 0.030, 0.990)

	if step % 4 == 0:
		bass_freq_current = _note_freq(root, bass_note)
		_pluck_string(bass_freq_current, float(profile.get("bass_gain", 0.13)) * 0.95, 0.996)
		for degree in chord:
			_pluck_string(_note_freq(root * 2.0, int(degree)), float(profile.get("harmony_gain", 0.05)) * 0.70, 0.992)

	if step % 8 == 4:
		harmony_freq_current = _note_freq(root * 2.0, harmony_note)
		harmony_level = 0.65
		_pluck_string(harmony_freq_current, float(profile.get("harmony_gain", 0.05)) * 0.55, 0.991)

func _emit_beat_hit(type):
	call_deferred("emit_signal", "beat_hit", type)

func _get_next_markov_note(current_note, markov_matrix):
	if typeof(markov_matrix) != TYPE_DICTIONARY:
		return current_note

	var transitions = markov_matrix.get(current_note, null)
	if typeof(transitions) != TYPE_DICTIONARY or transitions.is_empty():
		transitions = markov_matrix.get(int(stage_profiles[DEFAULT_STAGE_ID].get("melody_start", 0)), null)

	if typeof(transitions) != TYPE_DICTIONARY or transitions.is_empty():
		return SILENCE_NOTE

	var total_weight = 0
	for weight in transitions.values():
		total_weight += maxi(0, int(weight))

	if total_weight <= 0:
		return current_note

	var roll = rng.randi_range(1, total_weight)
	var running_weight = 0
	for note in transitions.keys():
		running_weight += maxi(0, int(transitions[note]))
		if roll <= running_weight:
			return int(note)

	return int(transitions.keys()[0])

func _pluck_string(freq, gain, decay):
	var size = clampi(int(sample_rate / maxf(freq, 24.0)), 18, 1800)
	var buffer = PackedFloat32Array()
	buffer.resize(size)
	for i in range(size):
		buffer[i] = rng.randf_range(-1.0, 1.0) * gain
	string_voices.append({
		"buffer": buffer,
		"index": 0,
		"decay": decay,
		"gain": 1.0
	})
	if string_voices.size() > 28:
		string_voices.pop_front()

func _process_string_voices():
	var output = 0.0
	for i in range(string_voices.size() - 1, -1, -1):
		var voice = string_voices[i]
		var buffer = voice["buffer"]
		var index = int(voice["index"])
		var next_index = (index + 1) % buffer.size()
		var current = float(buffer[index])
		var next = float(buffer[next_index])
		var filtered = (current + next) * 0.5 * float(voice["decay"])
		buffer[index] = filtered
		voice["buffer"] = buffer
		voice["index"] = next_index
		voice["gain"] = float(voice["gain"]) * 0.99972
		output += current * float(voice["gain"])
		string_voices[i] = voice
		if absf(float(voice["gain"])) < 0.02:
			string_voices.remove_at(i)
	return output

func _harmonica(phase):
	return _sine(phase) * 0.72 + sin(phase * TAU * 2.0) * 0.18 + sin(phase * TAU * 3.0) * 0.10

func _note_freq(root, semitone):
	return root * pow(2.0, float(semitone) / 12.0)

func _pluck_env(pos, length):
	if pos > length:
		return 0.0
	return pow(1.0 - pos / length, 1.8)

func _kick(step, step_pos, gain):
	var hit = step % 8 == 0 or (stage_id == "canyon" and step % 16 == 12) or (stage_id == "bonus" and step % 8 == 6)
	if not hit or step_pos > 0.24:
		return 0.0
	var env = pow(1.0 - step_pos / 0.24, 3.0)
	var tone = sin(phase_bass * TAU * (1.0 + env * 0.7))
	return tone * env * gain

func _snare(step, step_pos, gain):
	var hit = step % 16 == 8 or step % 16 == 14
	if stage_id == "mine":
		hit = step % 16 == 12
	if not hit or step_pos > 0.12:
		return 0.0
	var noise = rng.randf_range(-1.0, 1.0)
	return noise * pow(1.0 - step_pos / 0.12, 2.0) * gain

func _hat(step, step_pos, gain):
	var hit = step % 2 == 1
	if stage_id == "broken_fort":
		hit = step % 4 == 1 or step % 4 == 3
	if not hit or step_pos > 0.08:
		return 0.0
	var noise = rng.randf_range(-1.0, 1.0)
	var click = _square(phase_hat) * 0.5 + noise * 0.5
	return click * pow(1.0 - step_pos / 0.08, 2.0) * gain

func _osc(phase, wave):
	match wave:
		"saw":
			return _saw(phase)
		"square":
			return _square(phase) * 0.75 + _triangle(phase) * 0.25
		"sine":
			return _sine(phase)
		_:
			return _triangle(phase)

func _triangle(phase):
	return 4.0 * abs(phase - 0.5) - 1.0

func _square(phase):
	return 1.0 if phase < 0.5 else -1.0

func _saw(phase):
	return phase * 2.0 - 1.0

func _sine(phase):
	return sin(phase * TAU)
