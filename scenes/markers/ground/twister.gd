# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name Twister


func set_parameters(new_position: Vector3, lifetime: float, fail_conditions: Array) -> void:
	set_center_position(new_position)
	set_lifetime(lifetime)
	set_fail_conditions(fail_conditions)


func _on_body_entered(body: CharacterBody3D) -> void:
	check_fail([body])
	queue_free()
