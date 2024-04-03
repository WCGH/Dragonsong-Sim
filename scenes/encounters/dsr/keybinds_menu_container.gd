# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MarginContainer

enum {SPRINT, ARMS, DASH}

@onready var options_menu_container: MarginContainer = %OptionsMenuContainer
@onready var sprint_key_button: Button = %SprintKeyButton
@onready var arms_key_button: Button = %ArmsKeyButton
@onready var dash_key_button: Button = %DashKeyButton
@onready var buttons := [%SprintKeyButton, %ArmsKeyButton, %DashKeyButton]
var awaited_key: Variant
var saved_var_keys := ["ab1_sprint", "ab2_arms", "ab3_dash"]


func _ready() -> void:
	awaited_key = null
	sprint_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab1_sprint"]))
	arms_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab2_arms"]))
	dash_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab3_dash"]))


func _unhandled_input(event : InputEvent) -> void:
	if awaited_key == null:
		return
	# Only take in keyboard inputs.
	if event is InputEventKey:
		var keycode : int = event.get_keycode_with_modifiers()
		if keycode == KEY_SHIFT or keycode == KEY_CTRL or keycode == KEY_ALT:
			return
		GameEvents.emit_variable_saved("keybinds", saved_var_keys[awaited_key], keycode)
		buttons[awaited_key].set_text(OS.get_keycode_string(keycode))
		awaited_key = null


func _on_sprint_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = SPRINT
	sprint_key_button.set_text("Press Key")


func _on_arms_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = ARMS
	arms_key_button.set_text("Press Key")


func _on_dash_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = DASH
	dash_key_button.set_text("Press Key")


func _on_back_button_pressed() -> void:
	self.hide()
	options_menu_container.show()
