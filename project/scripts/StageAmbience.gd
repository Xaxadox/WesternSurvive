extends Node

const AudioMix = preload("res://scripts/AudioMix.gd")
const SAMPLE_RATE = 44100.0
const DEFAULT_STAGE_ID = "menu"
const MAX_PUSH_FRAMES = 2048

var generator: AudioStreamGenerator = null
var playback: AudioStreamGeneratorPlayback = null
var player: AudioStreamPlayer = null
var rng = RandomNumberGenerator.new()
var stage_id = DEFAULT_STAGE_ID
var sample_clock = 0
var phase_low = 0.0
var phase_event = 0.0
var phase_chirp = 0.0
var wind_left = 0.0
var wind_right = 0.0
var event_level = 0.0
var event_frequency = 420.0
var chirp_level = 0.0
var target_gain = 0.0
var current_gain = 0.0

var profiles = {
	"menu": {
		"gain": 0.18,
		"wind": 0.060,
		"wind_smooth": 0.0016,
		"low_freq": 38.0,
		"low_gain": 0.005,
		"event_rate": 0.10,
		"event_gain": 0.010,
		"event_decay": 0.99940,
		"event_min": 360.0,
		"event_max": 520.0,
		"chirp_rate": 0.00,
		"chirp_gain": 0.0
	},
	"ghost_town": {
		"gain": 0.22,
		"wind": 0.075,
		"wind_smooth": 0.0019,
		"low_freq": 34.0,
		"low_gain": 0.006,
		"event_rate": 0.24,
		"event_gain": 0.018,
		"event_decay": 0.99920,
		"event_min": 210.0,
		"event_max": 430.0,
		"chirp_rate": 0.04,
		"chirp_gain": 0.006
	},
	"canyon": {
		"gain": 0.20,
		"wind": 0.085,
		"wind_smooth": 0.0028,
		"low_freq": 44.0,
		"low_gain": 0.004,
		"event_rate": 0.12,
		"event_gain": 0.010,
		"event_decay": 0.99935,
		"event_min": 520.0,
		"event_max": 880.0,
		"chirp_rate": 0.20,
		"chirp_gain": 0.010
	},
	"broken_fort": {
		"gain": 0.23,
		"wind": 0.070,
		"wind_smooth": 0.0017,
		"low_freq": 29.0,
		"low_gain": 0.008,
		"event_rate": 0.30,
		"event_gain": 0.022,
		"event_decay": 0.99905,
		"event_min": 120.0,
		"event_max": 260.0,
		"chirp_rate": 0.03,
		"chirp_gain": 0.005
	},
	"mine": {
		"gain": 0.24,
		"wind": 0.040,
		"wind_smooth": 0.0011,
		"low_freq": 24.0,
		"low_gain": 0.010,
		"event_rate": 0.46,
		"event_gain": 0.026,
		"event_decay": 0.99880,
		"event_min": 760.0,
		"event_max": 1260.0,
		"chirp_rate": 0.02,
		"chirp_gain": 0.004
	},
	"bonus": {
		"gain": 0.19,
		"wind": 0.052,
		"wind_smooth": 0.0021,
		"low_freq": 52.0,
		"low_gain": 0.004,
		"event_rate": 0.18,
		"event_gain": 0.012,
		"event_decay": 0.99925,
		"event_min": 620.0,
		"event_max": 1040.0,
		"chirp_rate": 0.26,
		"chirp_gain": 0.012
	}
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		return

	AudioMix.ensure_buses()
	rng.randomize()
	generator = AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	generator.buffer_length = 0.24
	player = AudioStreamPlayer.new()
	player.stream = generator
	player.bus = AudioMix.BUS_AMBIENCE
	add_child(player)
	player.play()
	playback = player.get_stream_playback()
	configure(stage_id)

func _exit_tree():
	if player != null:
		player.stop()
	playback = null
	player = null
	generator = null

func configure(new_stage_id):
	stage_id = new_stage_id if profiles.has(new_stage_id) else DEFAULT_STAGE_ID
	var profile = profiles.get(stage_id, profiles[DEFAULT_STAGE_ID])
	target_gain = float(profile.get("gain", 0.18))
	event_level = 0.0
	chirp_level = 0.0

func _process(delta):
	if playback == null:
		return

	current_gain = move_toward(current_gain, target_gain, delta * 0.35)
	var frames = mini(playback.get_frames_available(), MAX_PUSH_FRAMES)
	if frames <= 0:
		return

	var profile = profiles.get(stage_id, profiles[DEFAULT_STAGE_ID])
	var chunk = PackedVector2Array()
	chunk.resize(frames)
	for i in range(frames):
		chunk[i] = _next_frame(profile)
	playback.push_buffer(chunk)

func _next_frame(profile):
	var wind_smooth = float(profile.get("wind_smooth", 0.0015))
	wind_left = lerpf(wind_left, rng.randf_range(-1.0, 1.0), wind_smooth)
	wind_right = lerpf(wind_right, rng.randf_range(-1.0, 1.0), wind_smooth * 0.83)

	phase_low = fmod(phase_low + float(profile.get("low_freq", 35.0)) / SAMPLE_RATE, 1.0)
	phase_event = fmod(phase_event + event_frequency / SAMPLE_RATE, 1.0)
	phase_chirp = fmod(phase_chirp + 6900.0 / SAMPLE_RATE, 1.0)

	if rng.randf() < float(profile.get("event_rate", 0.15)) / SAMPLE_RATE:
		event_level = 1.0
		event_frequency = rng.randf_range(float(profile.get("event_min", 240.0)), float(profile.get("event_max", 720.0)))

	if rng.randf() < float(profile.get("chirp_rate", 0.0)) / SAMPLE_RATE:
		chirp_level = 1.0

	var wind_gain = float(profile.get("wind", 0.05))
	var low = sin(phase_low * TAU) * float(profile.get("low_gain", 0.006))
	var event_sample = sin(phase_event * TAU) * event_level * float(profile.get("event_gain", 0.012))
	var chirp = _square(phase_chirp) * chirp_level * float(profile.get("chirp_gain", 0.0))

	event_level *= float(profile.get("event_decay", 0.99925))
	chirp_level *= 0.9975

	var left = (wind_left * wind_gain + low + event_sample + chirp) * current_gain
	var right = (wind_right * wind_gain + low + event_sample * 0.82 - chirp * 0.45) * current_gain
	sample_clock += 1
	return Vector2(left, right)

func _square(phase):
	return 1.0 if phase < 0.5 else -1.0
