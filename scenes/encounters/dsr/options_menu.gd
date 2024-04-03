# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MarginContainer

@onready var main_menu_container: MarginContainer = %MainMenuContainer
@onready var keybinds_menu_container: MarginContainer = %KeybindsMenuContainer
@onready var lineup_menu_container: MarginContainer = %LineupMenuContainer
@onready var strategy_select_button: OptionButton = %StrategySelectButton
@onready var markers_select_button: OptionButton = %MarkersSelectButton


func _ready() -> void:
	strategy_select_button.selected = SavedVariables.save_data["settings"]["strat"]
	markers_select_button.selected = SavedVariables.save_data["settings"]["markers"]


func _on_back_button_pressed() -> void:
	self.hide()
	main_menu_container.show()


func _on_strategy_select_button_item_selected(index: int) -> void:
	GameEvents.emit_variable_saved("settings", "strat", index)


func _on_markers_select_button_item_selected(index: int) -> void:
	GameEvents.emit_variable_saved("settings", "markers", index)


func _on_keybinds_button_pressed() -> void:
	self.hide()
	keybinds_menu_container.show()


func _on_doth_lineup_button_pressed() -> void:
	self.hide()
	lineup_menu_container.show()

