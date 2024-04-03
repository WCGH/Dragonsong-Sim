# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

@onready var sprint_action_button: ActionButton = $MarginContainer/ButtonsContainer/SprintActionButton
@onready var arms_action_button: ActionButton = $MarginContainer/ButtonsContainer/ArmsActionButton
@onready var dash_action_button: ActionButton = $MarginContainer/ButtonsContainer/DashActionButton

var player: Player
var keybinds: Dictionary
#"ab1_sprint": KEY_1,
#"ab2_arms": KEY_2,
#"ab3_dash": KEY_3


func _ready() -> void:
	GameEvents.party_ready.connect(on_party_ready)
	sprint_action_button.action_pressed.connect(on_sprint_pressed)
	arms_action_button.action_pressed.connect(on_arms_pressed)
	dash_action_button.action_pressed.connect(on_dash_pressed)
	SavedVariables.keybind_changed.connect(on_keybind_changed)
	keybinds = SavedVariables.get_keybinds()
	update_keybinds()


func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey:
		var keycode : int = event.get_keycode_with_modifiers()
		if keycode == keybinds["ab1_sprint"]:
			sprint_action_button._on_pressed()
		elif keycode == keybinds["ab2_arms"]:
			arms_action_button._on_pressed()
		elif keycode == keybinds["ab3_dash"]:
			dash_action_button._on_pressed()

#
#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ab1_sprint", true):
		#sprint_action_button._on_pressed()
	#if Input.is_action_just_pressed("ab2_arms", true):
		#arms_action_button._on_pressed()
	#if Input.is_action_just_pressed("ab3_dash", true):
		#dash_action_button._on_pressed()


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func on_keybind_changed(new_keybinds: Dictionary) -> void:
	keybinds = new_keybinds
	update_keybinds()


func update_keybinds() -> void:
	sprint_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab1_sprint"]))
	arms_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab2_arms"]))
	dash_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab3_dash"]))


func on_sprint_pressed() -> void:
	if !player:
		return
	player.sprint()


func on_arms_pressed() -> void:
	if !player:
		return
	player.arms_length()


func on_dash_pressed() -> void:
	if !player:
		return
	player.dash()
