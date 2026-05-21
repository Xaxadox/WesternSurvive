extends RefCounted

const SILENCE_NOTE = -99

static var STAGE_PROFILES = {
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
		"hat_gain": 0.025
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
		"hat_gain": 0.044
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
		"hat_gain": 0.062
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
		"hat_gain": 0.032
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
		"hat_gain": 0.024
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
		"hat_gain": 0.064
	}
}

static func stage_profiles():
	return STAGE_PROFILES.duplicate(true)
