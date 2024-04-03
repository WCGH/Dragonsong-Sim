# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends VBoxContainer
class_name Debuff

signal debuff_timeout(owner_key : String)

@onready var duration_label : Label = %Duration
@onready var timer : Timer = %Timer

var debuff_name : String
var remaining_duration := 20.0
var owner_key : String


func set_debuff(debuff_icon_scene : PackedScene, new_owner_key : String, debuff_duration := 0.0) -> void:
	owner_key = new_owner_key
	remaining_duration = debuff_duration
	%Duration.visible = remaining_duration > 0.0
	var new_debuff_icon : TextureRect = debuff_icon_scene.instantiate()
	debuff_name = new_debuff_icon.get_meta("debuff_name")
	self.add_child(new_debuff_icon)
	self.move_child(new_debuff_icon, 0)


# This debuff andles whole number durations only. For float durations, use debuff_float.
func _on_timer_timeout() -> void:
	remaining_duration -= 1.0
	if remaining_duration == 0:
		debuff_timeout.emit(owner_key)
		queue_free()
	duration_label.text = str("%.0f" % remaining_duration)
