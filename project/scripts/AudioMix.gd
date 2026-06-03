extends RefCounted

const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"
const BUS_UI = "UI"
const BUS_AMBIENCE = "Ambience"

const RUNTIME_BUSES = [
	BUS_MUSIC,
	BUS_SFX,
	BUS_UI,
	BUS_AMBIENCE
]

static func ensure_buses() -> void:
	for bus_name in RUNTIME_BUSES:
		_ensure_bus(bus_name)

static func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return

	var index = AudioServer.get_bus_count()
	AudioServer.add_bus(index)
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, BUS_MASTER)
	AudioServer.set_bus_volume_db(index, 0.0)
	AudioServer.set_bus_mute(index, false)
