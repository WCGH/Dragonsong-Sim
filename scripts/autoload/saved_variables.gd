# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

signal keybind_changed(keybinds: Dictionary)

const CONFIG_FILE_PATH = "user://config.cfg"

enum strats {APD, LPDU, TWIN}
enum markers {APD, LPDU}
enum nidhogg {WEST, EAST, DEFAULT}
enum dooms {ANCHOR, STATIC, DEFAULT}
enum wb_1 {HEALERS, RANGED, G1, DEFAULT}
enum wb_2 {FNOS, STATIC, DEFAULT}

var config_file: ConfigFile
var save_data: Dictionary = {
	"settings": {
		"player_role": 0,
		"screen_res": Vector2i(1600, 900),
		"maximized": false,
		"camera_distance": 22,
		"strat": strats.APD,
		"markers": markers.APD
	},
	"p3": {
		"nidhogg": nidhogg.DEFAULT
	},
	"p5": {
		"lineup": ["r1", "t1", "r2", "m1", "h2", "t2", "m2", "h1"],
		"dooms": dooms.DEFAULT
	},
	"p6": {
		"wb_1": wb_1.DEFAULT,
		"wb_2": wb_2.DEFAULT
	},
	"keybinds": {
		"ab1_sprint": KEY_1,
		"ab2_arms": KEY_2,
		"ab3_dash": KEY_3
	}
}

var defaults := {
	strats.APD: {
		"p3": { "nidhogg": nidhogg.WEST },
		"p5": { "dooms": dooms.ANCHOR },
		"p6": { "wb_1": wb_1.HEALERS, "wb_2": wb_2.STATIC}
	},
	strats.LPDU: {
		"p3": { "nidhogg": nidhogg.EAST },
		"p5": { "dooms": dooms.ANCHOR },
		"p6": { "wb_1": wb_1.G1, "wb_2": wb_2.FNOS}
	},
	strats.TWIN: {
		"p3": { "nidhogg": nidhogg.EAST },
		"p5": { "dooms": dooms.STATIC },
		"p6": { "wb_1": wb_1.G1, "wb_2": wb_2.FNOS}
	}
}

var input_action_keys := ["ab1_sprint", "ab2_arms", "ab3_dash"]


func _ready() -> void:
	GameEvents.variable_saved.connect(on_variable_saved)
	config_file = ConfigFile.new()
	load_save_file()
	set_defaults()
	set_keybinds()


func load_save_file() -> void:
	var _err := config_file.load(CONFIG_FILE_PATH)
	
	# Fix out of date settings
	if config_file.get_value("settings", "strat") is String:
		config_file.set_value("settings", "strat", save_data["settings"]["strat"])
	if config_file.has_section_key("settings", "lineup"):
		config_file.set_value("settings", "lineup", null)
	
	for section in config_file.get_sections():
		for key in config_file.get_section_keys(section):
			save_data[section][key] = config_file.get_value(section, key)


func save() -> void:
	var err := config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		print("Error saving config file: ", err)


func set_defaults() -> void:
	for section: String in save_data:
		for key: String in save_data[section]:
			config_file.set_value(section, key, save_data[section][key])


func on_variable_saved(section: String, key: String, value: Variant) -> void:
	save_data[section][key] = value
	config_file.set_value(section, key, value)
	save()
	if section == "keybinds":
		set_keybinds()


func set_keybinds() -> void:
	for key: String in save_data["keybinds"]:
		var new_key_event := InputEventKey.new()
		new_key_event.set_keycode(save_data["keybinds"][key])
		if !InputMap.action_has_event(key, new_key_event):
			InputMap.action_erase_events(key)
			InputMap.action_add_event(key, new_key_event)
	keybind_changed.emit(save_data["keybinds"])


func get_keybinds() -> Dictionary:
	return save_data["keybinds"]


func get_screen_res() -> Vector2i:
	return save_data["settings"]["screen_res"]


func get_default(category: String, key: String) -> int:
	#var a = defaults[strats.APD][category][key]
	return defaults[save_data["settings"]["strat"]][category][key]
