# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

@export var waymark_apd_scene: PackedScene
@export var waymark_lpdu_scene: PackedScene
@export var waymark_mana_scene: PackedScene
@export var arena_node: Node3D

func _ready() -> void:
	var selected_wm: int = SavedVariables.save_data["settings"]["markers"]
	if selected_wm == SavedVariables.markers.APD:
		var new_waymarks: Node3D = waymark_apd_scene.instantiate()
		arena_node.add_child(new_waymarks)
	if selected_wm == SavedVariables.markers.MANA:
		var new_waymarks: Node3D = waymark_mana_scene.instantiate()
		arena_node.add_child(new_waymarks)
	else:
		var new_waymarks: Node3D = waymark_lpdu_scene.instantiate()
		arena_node.add_child(new_waymarks)
