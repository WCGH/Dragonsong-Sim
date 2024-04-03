# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Lockon Controller
## Handles the loading and instantiation of lockon nodes.
## When adding a new lockon node:
##  - Add node to enums.
##  - Add res path and meta id#.
##  - Add meta id# to root node in new lockon scene.

# TODO: Add hide/show functionality here if we need in the future.

extends Node
class_name LockonController

enum {PS_CROSS, PS_CIRCLE, PS_SQUARE, PS_TRIANGLE,
	DEFAM, DIVEBOMB, DOOM, LC_1, LC_2, LC_3}

var res_paths := {
	PS_CROSS: "res://scenes/markers/lockon/playstation/ps_cross.tscn",
	PS_CIRCLE: "res://scenes/markers/lockon/playstation/ps_circle.tscn",
	PS_SQUARE: "res://scenes/markers/lockon/playstation/ps_square.tscn",
	PS_TRIANGLE: "res://scenes/markers/lockon/playstation/ps_triangle.tscn",
	DEFAM: "res://scenes/markers/lockon/defam.tscn",
	DIVEBOMB: "res://scenes/markers/lockon/divebomb.tscn",
	DOOM: "res://scenes/markers/lockon/doom.tscn",
	LC_1: "res://scenes/markers/lockon/limit_cut/lc_1.tscn",
	LC_2: "res://scenes/markers/lockon/limit_cut/lc_2.tscn",
	LC_3: "res://scenes/markers/lockon/limit_cut/lc_3.tscn"
}
var meta_ids := {
	PS_CROSS: 0, PS_CIRCLE: 1, PS_SQUARE: 2, PS_TRIANGLE: 3,
	DEFAM: 4, DIVEBOMB: 5, DOOM: 6, LC_1: 7, LC_2: 8, LC_3: 9
}

var lockon_node_path := "Lockon"
var loaded_scenes: Dictionary


func pre_load(lockon_id_list: Array) -> void:
	for lockon_id: int in lockon_id_list:
		ResourceLoader.load_threaded_request(res_paths[lockon_id])


func add_marker(lockon_id: int, target: Node3D) -> void:
	assert(target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	if !loaded_scenes.has(lockon_id):
		loaded_scenes[lockon_id] = ResourceLoader.load_threaded_get(res_paths[lockon_id])
	var new_marker: Node3D = loaded_scenes[lockon_id].instantiate()
	target.get_node(lockon_node_path).add_child(new_marker)


# Returns true if successful.
func remove_marker(lockon_id: int, target: Node3D) -> bool:
	assert(target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	var lockon_nodes := target.get_node(lockon_node_path).get_children()
	for node in lockon_nodes:
		assert(node.has_meta("id"), "Error. Missing lockon node meta data (id).")
		if node.get_meta("id") == meta_ids[lockon_id]:
			node.queue_free()
			return true
	return false
