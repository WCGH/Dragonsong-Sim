# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name GroundAoeController

@onready var marker_layer : Node3D = get_tree().get_first_node_in_group("ground_marker_layer")
@onready var res_path := {
	"circle": "res://scenes/markers/ground/circle_aoe.tscn",
	"donut": "res://scenes/markers/ground/donut_aoe.tscn",
	"line": "res://scenes/markers/ground/line_aoe.tscn",
	"tower": "res://scenes/markers/ground/tower_aoe.tscn",
	"cone": "res://scenes/markers/ground/cone_aoe.tscn",
	"twister": "res://scenes/markers/ground/twister.tscn",
	"ascalon": "res://scenes/markers/ground/ascalon_cone.tscn"
}

var circle_aoe_scene : PackedScene
var donut_aoe_scene : PackedScene
var line_aoe_scene : PackedScene
var tower_aoe_scene : PackedScene
var cone_aoe_scene : PackedScene
var ascalon_cone_scene : PackedScene
var twister_scene : PackedScene


func preload_aoe(aoe_keys: Array) -> void:
	for key: String in aoe_keys:
		ResourceLoader.load_threaded_request(res_path[key])


func clear_all() -> void:
	for marker: Node3D in marker_layer.get_children():
		marker.queue_free()


func spawn_circle(position: Vector2, radius: float, lifetime: float,
color: Color, fail_conditions: Array = [], check_at_end: bool = false) -> CircleAoe:
	# Load resource
	if !circle_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["circle"]) == 0:
			ResourceLoader.load_threaded_request(res_path["circle"])
		circle_aoe_scene = ResourceLoader.load_threaded_get(res_path["circle"])
	# Spawn circle
	var new_circle: CircleAoe = circle_aoe_scene.instantiate()
	marker_layer.add_child(new_circle)
	new_circle.set_parameters(Vector3(position.x, 0, position.y), radius,
		lifetime, color, fail_conditions, check_at_end)
	new_circle.play_start_animation()
	if !check_at_end:
		new_circle.await_collision()
	return new_circle


# TODO: missing check at end
func spawn_donut(position: Vector2, inner_radius: float,
	outter_radius: float, lifetime: float, color: Color,
	fail_conditions := [], check_at_end := false) -> DonutAoe:
	# Load resource
	if !donut_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["donut"]) == 0:
			ResourceLoader.load_threaded_request(res_path["donut"])
		donut_aoe_scene = ResourceLoader.load_threaded_get(res_path["donut"])
	# Spawn donut
	var new_donut: DonutAoe = donut_aoe_scene.instantiate()
	marker_layer.add_child(new_donut)
	new_donut.set_parameters(Vector3(position.x, 0, position.y), inner_radius, outter_radius,
		lifetime, color, fail_conditions)
	if check_at_end:
		new_donut.check_at_end()
	else:
		new_donut.await_collision()
	return new_donut


func spawn_line(position: Vector2, width: float, length: float,
	target: Vector2, lifetime: float, color: Color,
	fail_conditions := [], check_at_end := false) -> LineAoe:
	# Load resource
	if !line_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["line"]) == 0:
			ResourceLoader.load_threaded_request(res_path["line"])
		line_aoe_scene = ResourceLoader.load_threaded_get(res_path["line"])
	var new_line: LineAoe = line_aoe_scene.instantiate()
	marker_layer.add_child(new_line)
	new_line.set_parameters(Vector3(position.x, 0, position.y), width, length,
	 target, lifetime, color, fail_conditions)
	new_line.play_start_animation()
	if check_at_end:
		new_line.check_at_end()
	else:
		new_line.await_collision()
	return new_line


# TODO: missing check at end
# Returns a reference to tower to be called later for collision check
func spawn_tower(position: Vector2, radius: float, lifetime: float, color: Color) -> TowerAoe:
	# Load resource
	if !tower_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["tower"]) == 0:
			ResourceLoader.load_threaded_request(res_path["tower"])
		tower_aoe_scene = ResourceLoader.load_threaded_get(res_path["tower"])
	# Spawn new tower
	var new_tower: TowerAoe = tower_aoe_scene.instantiate()
	marker_layer.add_child(new_tower)
	new_tower.set_parameters(Vector3(position.x, 0, position.y), radius, lifetime, color)
	new_tower.play_start_animation()
	return new_tower


# TODO: missing check at end
func spawn_cone(position: Vector2, angle_deg: float, length: float,
target: Vector2, lifetime: float, color: Color,
fail_conditions: Array = [], check_at_end : bool = false) -> ConeAoe:
	# Load resource
	if !cone_aoe_scene:
		if ResourceLoader.load_threaded_get_status(res_path["cone"]) == 0:
			ResourceLoader.load_threaded_request(res_path["cone"])
		cone_aoe_scene = ResourceLoader.load_threaded_get(res_path["cone"])
	var new_cone: ConeAoe = cone_aoe_scene.instantiate()
	marker_layer.add_child(new_cone)
	new_cone.set_parameters(Vector3(position.x, 0, position.y), angle_deg, length,
		target, lifetime, color, fail_conditions)
	new_cone.play_start_animation()
	new_cone.await_collision()
	if check_at_end:
		new_cone.check_at_end()
	else:
		new_cone.await_collision()
	return new_cone


func spawn_ascalon_cone(position: Vector2, target: Vector2, lifetime: float, 
color: Color, fail_conditions: Array = []) -> AscalonCone:
	# Load resource
	if !ascalon_cone_scene:
		if ResourceLoader.load_threaded_get_status(res_path["ascalon"]) == 0:
			ResourceLoader.load_threaded_request(res_path["ascalon"])
		ascalon_cone_scene = ResourceLoader.load_threaded_get(res_path["ascalon"])
	# Spawn Ascalon Cone
	var new_cone: AscalonCone = ascalon_cone_scene.instantiate()
	marker_layer.add_child(new_cone)
	new_cone.set_parameters(Vector3(position.x, 0, position.y), target, lifetime, color, fail_conditions)
	new_cone.play_start_animation()
	new_cone.await_collision()
	return new_cone


func spawn_twister(position: Vector2, lifetime: float, fail_conditions: Array = []) -> Twister:
	# Load resource
	if !twister_scene:
		if ResourceLoader.load_threaded_get_status(res_path["twister"]) == 0:
			ResourceLoader.load_threaded_request(res_path["twister"])
		twister_scene = ResourceLoader.load_threaded_get(res_path["twister"])
	# Spawn Twister
	var new_twister: Twister = twister_scene.instantiate()
	marker_layer.add_child(new_twister)
	new_twister.set_parameters(Vector3(position.x, 0, position.y), lifetime, fail_conditions)
	return new_twister



## Deprecated

# Returns array of CharacterBody3D's hit by AoE
#func spawn_circle_with_hitbox(position: Vector2, radius: float, lifetime: float, color: Color) -> Array:
	#var new_circle: CircleAoe = circle_aoe_scene.instantiate()
	#marker_layer.add_child(new_circle)
	#new_circle.set_parameters(Vector3(position.x, 0, position.y), radius, lifetime, color)
	#new_circle.play_start_animation()
	#var bodies_hit: Array = await new_circle.get_collisions()
	#return bodies_hit


#func spawn_donut_with_hitbox(position: Vector2, inner_radius: float,
	#outter_radius: float, lifetime: float, color: Color) -> Array:
	#var new_donut: DonutAoe = donut_aoe_scene.instantiate()
	#marker_layer.add_child(new_donut)
	#new_donut.set_parameters(Vector3(position.x, 0, position.y), inner_radius, outter_radius, lifetime, color)
	#new_donut.play_start_animation()
	#var bodies_hit: Array = await new_donut.get_collisions()
	#return bodies_hit


#func spawn_line_with_hitbox(position: Vector2, width: float, length: float,
	#target: Vector2, lifetime: float, color: Color) -> Array:
	#var new_line: LineAoe = line_aoe_scene.instantiate()
	#marker_layer.add_child(new_line)
	#new_line.set_parameters(Vector3(position.x, 0, position.y), width, length, target, lifetime, color)
	#new_line.play_start_animation()
	#var bodies_hit: Array = await new_line.get_collisions()
	#return bodies_hit
