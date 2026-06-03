extends Node

const AudioMix = preload("res://scripts/AudioMix.gd")
const SAMPLE_RATE = 44100
const TARGET_PEAK = 0.86
const MAX_PLAYERS = 8

var streams = {}
var players = []
var rng = RandomNumberGenerator.new()

var stinger_profiles = {
	"stage_start": {"duration": 0.62, "volume_db": -4.0, "pitch_jitter": 0.012},
	"level_up": {"duration": 0.56, "volume_db": -3.0, "pitch_jitter": 0.010},
	"upgrade_select": {"duration": 0.26, "volume_db": -5.0, "pitch_jitter": 0.018},
	"unlock": {"duration": 0.72, "volume_db": -3.0, "pitch_jitter": 0.010},
	"bonus_unlock": {"duration": 0.92, "volume_db": -2.5, "pitch_jitter": 0.008},
	"player_down": {"duration": 0.42, "volume_db": -5.0, "pitch_jitter": 0.010},
	"game_over": {"duration": 1.05, "volume_db": -3.5, "pitch_jitter": 0.006}
}

func _ready():
	AudioMix.ensure_buses()
	rng.randomize()
	_ensure_streams()

func _ensure_streams():
	for stinger_id in stinger_profiles.keys():
		if not streams.has(stinger_id):
			streams[stinger_id] = _build_stream(stinger_id)

func play_stinger(stinger_id):
	_ensure_streams()
	var stream = streams.get(stinger_id, null)
	if stream == null:
		return

	var profile = stinger_profiles.get(stinger_id, {})
	var player = _available_player()
	player.stream = stream
	player.volume_db = float(profile.get("volume_db", -6.0))
	var jitter = float(profile.get("pitch_jitter", 0.01))
	player.pitch_scale = rng.randf_range(1.0 - jitter, 1.0 + jitter)
	player.play()

func _available_player():
	for player in players:
		if not player.playing:
			return player

	return _create_player()

func _create_player():
	var player = AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = AudioMix.BUS_UI
	add_child(player)
	players.append(player)
	if players.size() > MAX_PLAYERS:
		var oldest = players.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	return player

func _build_stream(stinger_id):
	var profile = stinger_profiles.get(stinger_id, {})
	var duration = float(profile.get("duration", 0.35))
	var frames = maxi(1, int(SAMPLE_RATE * duration))
	var samples = PackedFloat32Array()
	samples.resize(frames)
	var peak = 0.0

	for i in range(frames):
		var t = float(i) / float(SAMPLE_RATE)
		var sample = clampf(_sample_stinger(stinger_id, t, duration, i), -1.0, 1.0)
		samples[i] = sample
		peak = maxf(peak, absf(sample))

	var gain = TARGET_PEAK / peak if peak > 0.001 else 1.0
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var sample = clampf(samples[i] * gain, -1.0, 1.0)
		data.encode_s16(i * 2, int(sample * 32767.0))

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream

func _sample_stinger(stinger_id, t, duration, index):
	match stinger_id:
		"stage_start":
			return _arpeggio(t, [57, 60, 64, 69], 0.105, 0.30, 0.92) + _noise_tail(t, duration, index, 0.050)
		"level_up":
			return _arpeggio(t, [60, 64, 67, 72], 0.075, 0.34, 0.88) + _bell(t, 0.18, 84, 0.26)
		"upgrade_select":
			return _bell(t, 0.0, 72, 0.38) + _bell(t, 0.055, 79, 0.22)
		"unlock":
			return _arpeggio(t, [55, 62, 67, 74, 79], 0.080, 0.28, 0.86) + _bell(t, 0.36, 86, 0.24)
		"bonus_unlock":
			return _arpeggio(t, [60, 67, 72, 76, 79, 84], 0.070, 0.32, 0.88) + _bell(t, 0.50, 91, 0.24)
		"player_down":
			return _descending_hit(t, [62, 58, 55], 0.070, 0.38) + _noise_tail(t, duration, index, 0.026)
		"game_over":
			return _descending_hit(t, [57, 54, 48, 45], 0.145, 0.74) + _low_thud(t, duration, 0.24)
		_:
			return 0.0

func _arpeggio(t, notes, step_time, sustain, gain):
	var output = 0.0
	for i in range(notes.size()):
		var local_t = t - float(i) * step_time
		if local_t < 0.0:
			continue
		output += _tone(local_t, sustain, _midi_freq(int(notes[i])), gain * 0.48, 3.2)
	return output

func _descending_hit(t, notes, step_time, sustain):
	var output = 0.0
	for i in range(notes.size()):
		var local_t = t - float(i) * step_time
		if local_t < 0.0:
			continue
		output += _tone(local_t, sustain, _midi_freq(int(notes[i])), 0.42, 2.3)
	return output

func _bell(t, delay, midi_note, gain):
	if t < delay:
		return 0.0

	var local_t = t - delay
	var freq = _midi_freq(midi_note)
	var env = pow(maxf(0.0, 1.0 - local_t / 0.38), 4.0)
	return (sin(TAU * freq * local_t) * 0.72 + sin(TAU * freq * 2.01 * local_t) * 0.22) * env * gain

func _low_thud(t, duration, gain):
	var env = pow(maxf(0.0, 1.0 - t / duration), 5.5)
	var sweep_freq = 94.0 - 42.0 * clampf(t / duration, 0.0, 1.0)
	return sin(TAU * sweep_freq * t) * env * gain

func _noise_tail(t, duration, index, gain):
	var env = pow(maxf(0.0, 1.0 - t / duration), 3.0)
	return _noise(index, 19.7) * env * gain

func _tone(t, duration, freq, gain, decay_power):
	if t > duration:
		return 0.0
	var env = pow(maxf(0.0, 1.0 - t / duration), decay_power)
	return (sin(TAU * freq * t) * 0.68 + _triangle(fmod(freq * t, 1.0)) * 0.22) * env * gain

func _midi_freq(note):
	return 440.0 * pow(2.0, float(note - 69) / 12.0)

func _triangle(phase):
	return 4.0 * abs(phase - 0.5) - 1.0

func _noise(index, seed):
	var value = sin((float(index) + seed) * 12.9898) * 43758.5453
	return (value - floor(value)) * 2.0 - 1.0
