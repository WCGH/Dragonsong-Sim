# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton


func _ready() -> void:
	selected = Global.selected_sequence_index


func _on_item_selected(index : int) -> void:
	Global.selected_sequence_index = index
