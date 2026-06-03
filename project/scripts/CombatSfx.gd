extends Node

const AudioMix = preload("res://scripts/AudioMix.gd")
const SAMPLE_RATE = 44100
const TARGET_PEAK = 0.90
const MAX_PLAYERS = 20

var streams = {}
var players = []
var last_play_msec = {}
var rng = RandomNumberGenerator.new()

var effect_profiles = {
	"enemy_hit": {"duration": 0.10, "volume_db": -8.0, "pitch_jitter": 0.050, "cooldown": 0.035},
	"enemy_down": {"duration": 0.22, "volume_db": -6.0, "pitch_jitter": 0.035, "cooldown": 0.030},
	"player_damage": {"duration": 0.24, "volume_db": -4.5, "pitch_jitter": 0.020, "cooldown": 0.090},
	"xp_pickup": {"duration": 0.13, "volume_db": -10.0, "pitch_jitter": 0.055, "cooldown": 0.040},
	"heal_pickup": {"duration": 0.28, "volume_db": -7.0, "pitch_jitter": 0.025, "cooldown": 0.060},
	"explosion": {"duration": 0.42, "volume_db": -4.5, "pitch_jitter": 0.020, "cooldown": 0.080}
}

func _ready():
	AudioMix.ensure_buses()
	rng.randomize()
	_ensure_streams()

func _ensure_streams():
	for effect_id in effect_profiles.keys():
		if not streams.has(effect_id):
			streams[effect_id] = _build_stream(effect_id)

func play_effect(effect_id):
	_ensure_streams()
	var stream = streams.get(effect_id, null)
	if stream == null or _is_rate_limited(effect_id):
		return

	var profile = effect_profiles.get(effect_id, {})
	var player = _available_player()
	player.stream = stream
	player.volume_db = float(profile.get("volume_db", -8.0))
	var jitter = float(profile.get("pitch_jitter", 0.03))
	player.pitch_scale = rng.randf_range(1.0 - jitter, 1.0 + jitter)
	player.play()

func _is_rate_limited(effect_id):
	var now = Time.get_ticks_msec()
	var cooldown_ms = int(float(effect_profiles.get(effect_id, {}).get("cooldown", 0.02)) * 1000.0)
	var last = int(last_play_msec.get(effect_id, -1000000))
	if now - last < cooldown_ms:
		return true
	last_play_msec[effect_id] = now
	return false

func _available_player():
	for player in players:
		if not player.playing:
			return player

	return _create_player()

func _create_player():
	var player = AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = AudioMix.BUS_SFX
	add_child(player)
	players.append(player)
	if players.size() > MAX_PLAYERS:
		var oldest = players.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	return player

func _build_stream(effect_id):
	var profile = effect_profiles.get(effect_id, {})
	var duration = float(profile.get("duration", 0.20))
	var frames = maxi(1, int(SAMPLE_RATE * duration))
	var samples = PackedFloat32Array()
	samples.resize(frames)
	var peak = 0.0

	for i in range(frames):
		var t = float(i) / float(SAMPLE_RATE)
		var sample = clampf(_sample_effect(effect_id, t, duration, i), -1.0, 1.0)
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

func _sample_effect(effect_id, t, duration, index):
	match effect_id:
		"enemy_hit":
			return _noise(index, 11.3) * _decay(t, duration, 5.5) * 0.36 + _tone(t, 0.07, 760.0, 0.18, 6.0)
		"enemy_down":
			return _tone(t, duration, 170.0, 0.26, 3.4) + _noise(index, 28.7) * _decay(t, duration, 3.0) * 0.20
		"player_damage":
			return _tone(t, duration, 92.0, 0.34, 3.2) + _noise(index, 41.2) * _decay(t, 0.10, 4.0) * 0.28
		"xp_pickup":
			return _tone(t, 0.13, 1320.0, 0.18, 4.2) + _tone(maxf(t - 0.030, 0.0), 0.10, 1760.0, 0.11, 5.0)
		"heal_pickup":
			return _tone(t, duration, 660.0, 0.16, 3.2) + _tone(maxf(t - 0.080, 0.0), 0.20, 990.0, 0.18, 3.4)
		"explosion":
			return _tone(t, duration, 74.0, 0.42, 5.0) + _noise(index, 72.4) * _decay(t, duration, 2.2) * 0.36
		_:
			return 0.0

func _tone(t, duration, freq, gain, decay_power):
	if t > duration:
		return 0.0
	return sin(TAU * freq * t) * gain * _decay(t, duration, decay_power)

func _decay(t, duration, power):
	return pow(maxf(0.0, 1.0 - t / maxf(duration, 0.001)), power)

func _noise(index, seed):
	var value = sin((float(index) + seed) * 12.9898) * 43758.5453
	return (value - floor(value)) * 2.0 - 1.0
