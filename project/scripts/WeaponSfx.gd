extends Node

const AudioMix = preload("res://scripts/AudioMix.gd")
const SAMPLE_RATE = 44100
const MAX_PLAYERS = 18
const PREWARM_PLAYERS = 8
const TARGET_PEAK = 0.92

var streams = {}
var rng = RandomNumberGenerator.new()
var players = []

var sound_profiles = {
	"revolver": {"duration": 0.16, "volume_db": -2.0, "pitch_jitter": 0.035},
	"golden_revolver": {"duration": 0.18, "volume_db": -1.0, "pitch_jitter": 0.04},
	"shotgun": {"duration": 0.32, "volume_db": -1.0, "pitch_jitter": 0.025},
	"coach_gun": {"duration": 0.38, "volume_db": 0.0, "pitch_jitter": 0.025},
	"rifle": {"duration": 0.22, "volume_db": -1.5, "pitch_jitter": 0.025},
	"rail_spike": {"duration": 0.30, "volume_db": -1.0, "pitch_jitter": 0.02},
	"dynamite": {"duration": 0.34, "volume_db": -3.0, "pitch_jitter": 0.035},
	"fire_bottle": {"duration": 0.42, "volume_db": -3.0, "pitch_jitter": 0.03},
	"lasso": {"duration": 0.30, "volume_db": -4.0, "pitch_jitter": 0.04},
	"knife": {"duration": 0.18, "volume_db": -4.0, "pitch_jitter": 0.06},
	"horseshoe": {"duration": 0.26, "volume_db": -3.0, "pitch_jitter": 0.05},
	"ghost_lantern": {"duration": 0.44, "volume_db": -3.0, "pitch_jitter": 0.03}
}

func _ready():
	AudioMix.ensure_buses()
	rng.randomize()
	_ensure_streams()
	for i in range(PREWARM_PLAYERS):
		_create_player()

func _ensure_streams():
	for weapon_id in sound_profiles.keys():
		if not streams.has(weapon_id):
			streams[weapon_id] = _build_stream(weapon_id)

func play_weapon(weapon_id):
	_ensure_streams()
	var stream = streams.get(weapon_id, null)
	if stream == null:
		return

	var profile = sound_profiles.get(weapon_id, {})
	var player = _available_player()
	player.stream = stream
	player.volume_db = float(profile.get("volume_db", -10.0))
	var jitter = float(profile.get("pitch_jitter", 0.03))
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
	player.bus = AudioMix.BUS_SFX
	add_child(player)
	players.append(player)
	if players.size() > MAX_PLAYERS:
		var oldest = players.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	return player

func _build_stream(weapon_id):
	var profile = sound_profiles.get(weapon_id, {})
	var duration = float(profile.get("duration", 0.20))
	var frames = maxi(1, int(SAMPLE_RATE * duration))
	var data = PackedByteArray()
	data.resize(frames * 2)
	var samples = PackedFloat32Array()
	samples.resize(frames)
	var peak = 0.0

	for i in range(frames):
		var t = float(i) / float(SAMPLE_RATE)
		var sample = clampf(_sample_weapon(weapon_id, t, duration, i), -1.0, 1.0)
		samples[i] = sample
		peak = maxf(peak, absf(sample))

	var gain = TARGET_PEAK / peak if peak > 0.001 else 1.0
	for i in range(frames):
		var sample = clampf(samples[i] * gain, -1.0, 1.0)
		data.encode_s16(i * 2, int(sample * 32767.0))

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream

func _sample_weapon(weapon_id, t, duration, index):
	match weapon_id:
		"revolver":
			return _gun_crack(t, duration, index, 780.0, 0.70, 0.58) + _metal_click(t, 0.055, 0.24, 1220.0)
		"golden_revolver":
			return _gun_crack(t, duration, index, 920.0, 0.68, 0.62) + _metal_click(t, 0.040, 0.28, 1780.0) + _metal_click(t, 0.090, 0.18, 1350.0)
		"shotgun":
			return _boom(t, duration, index, 0.78, 82.0) + _noise_burst(t, duration, index, 0.52, 2.8)
		"coach_gun":
			return _boom(t, duration, index, 0.92, 64.0) + _noise_burst(t, duration, index, 0.62, 2.2) + _metal_click(t, 0.070, 0.16, 520.0)
		"rifle":
			return _gun_crack(t, duration, index, 1180.0, 0.48, 0.70) + _tone(t, duration, 210.0, 0.18, 5.0)
		"rail_spike":
			return _gun_crack(t, duration, index, 1500.0, 0.34, 0.58) + _metal_click(t, 0.025, 0.42, 2400.0) + _tone(t, duration, 96.0, 0.22, 4.2)
		"dynamite":
			return _thump(t, duration, 96.0, 0.42) + _fuse_hiss(t, duration, index, 0.30)
		"fire_bottle":
			return _whoosh(t, duration, index, 0.42) + _glass_ping(t, duration, 0.24)
		"lasso":
			return _rope_whip(t, duration, index)
		"knife":
			return _blade_swish(t, duration, index)
		"horseshoe":
			return _metal_click(t, 0.000, 0.42, 720.0) + _metal_click(t, 0.055, 0.34, 1120.0) + _tone(t, duration, 360.0, 0.16, 7.0)
		"ghost_lantern":
			return _ghost_chime(t, duration, index)
		_:
			return 0.0

func _gun_crack(t, duration, index, tone_freq, tone_gain, noise_gain):
	var snap = _noise_burst(t, minf(duration, 0.075), index, noise_gain, 9.0)
	var tone = _tone(t, duration, tone_freq, tone_gain, 18.0)
	return (snap + tone) * _attack(t, 0.003)

func _boom(t, duration, index, gain, low_freq):
	var low = _tone(t, duration, low_freq, gain, 7.0)
	var mid = _tone(t, duration, low_freq * 2.1, gain * 0.18, 9.0)
	return (low + mid) * _attack(t, 0.006)

func _thump(t, duration, freq, gain):
	return _tone(t, duration, freq, gain, 6.0) * _attack(t, 0.012)

func _noise_burst(t, duration, index, gain, decay_power):
	if t > duration:
		return 0.0
	return _noise(index, 31.7) * gain * pow(1.0 - t / duration, decay_power)

func _fuse_hiss(t, duration, index, gain):
	var fade_in = clampf(t / 0.030, 0.0, 1.0)
	var fade_out = pow(maxf(0.0, 1.0 - t / duration), 1.5)
	return _noise(index, 91.1) * gain * fade_in * fade_out

func _whoosh(t, duration, index, gain):
	var sweep = sin(TAU * (170.0 + 860.0 * t / duration) * t) * 0.20
	return (_noise(index, 17.3) * 0.70 + sweep) * gain * sin(PI * clampf(t / duration, 0.0, 1.0))

func _glass_ping(t, duration, gain):
	return _tone(maxf(0.0, t - 0.08), maxf(0.01, duration - 0.08), 1460.0, gain, 10.0)

func _rope_whip(t, duration, index):
	var center = 0.11
	var width = 0.075
	var sweep_pos = clampf(1.0 - absf(t - center) / width, 0.0, 1.0)
	var sweep = sin(TAU * (240.0 + 1700.0 * t) * t) * sweep_pos * 0.48
	var air = _noise(index, 44.9) * sweep_pos * 0.22
	return sweep + air

func _blade_swish(t, duration, index):
	var sweep = sin(PI * clampf(t / duration, 0.0, 1.0))
	var bright = sin(TAU * (1700.0 + 650.0 * t) * t) * 0.18
	return (_noise(index, 63.2) * 0.38 + bright) * sweep

func _ghost_chime(t, duration, index):
	var fade = pow(maxf(0.0, 1.0 - t / duration), 1.8)
	var chime = sin(TAU * 520.0 * t) * 0.28 + sin(TAU * 777.0 * t) * 0.20 + sin(TAU * 1040.0 * t) * 0.12
	var breath = _noise(index, 128.5) * 0.11 * sin(PI * clampf(t / duration, 0.0, 1.0))
	return (chime + breath) * fade

func _metal_click(t, delay, gain, freq):
	if t < delay:
		return 0.0
	var local_t = t - delay
	return sin(TAU * freq * local_t) * gain * pow(maxf(0.0, 1.0 - local_t / 0.11), 8.0)

func _tone(t, duration, freq, gain, decay_power):
	if t > duration:
		return 0.0
	return sin(TAU * freq * t) * gain * pow(maxf(0.0, 1.0 - t / duration), decay_power)

func _attack(t, attack_time):
	return clampf(t / maxf(attack_time, 0.001), 0.0, 1.0)

func _noise(index, seed):
	var value = sin((float(index) + seed) * 12.9898) * 43758.5453
	return (value - floor(value)) * 2.0 - 1.0
