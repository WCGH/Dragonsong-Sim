# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Sequence


func _on_reset_button_pressed() -> void:
	Global.vow_target_key = ""
	save_variables()
	get_tree().reload_current_scene()
