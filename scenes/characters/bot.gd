# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Bot Controller
## Instantiate alongside set_parameters.

extends PlayableCharacter

@export var move_speed : = 14.3
@export var acceleration : = 20.0
@export var gravity : = 25.0
@export var bot_scale := 1.25
@export var model_scene : PackedScene

var facing_angle: float
var rotation_speed := 0.7
var target: Vector3
var at_target := true
var look_direction := Vector3.ZERO
var xiv_model : bool

func _ready() -> void:
	model = model_scene.instantiate()
	add_child(model)
	xiv_model = model.get_meta("xiv_model", false)
	model.scale = Vector3.ONE * bot_scale
	anim_tree = model.get_node("AnimationTree")
	anim_state = model.get_node("AnimationTree").get("parameters/playback")
	look_at_direction(look_direction)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
	elif !at_target and !sliding:
		# Move bot
		_move_to_target()
		# Check if arrived
		if global_position.distance_squared_to(target) < 0.1:
			look_at_direction(look_direction)
			if xiv_model:
				anim_tree.set("parameters/conditions/idle", true)
				anim_tree.set("parameters/conditions/running", false)
			else:
				anim_tree.set("parameters/IWR/blend_position", Vector2.ZERO)
			at_target = true


func _move_to_target() -> void:
	var dir := global_position.direction_to(target)
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	if velocity != Vector3.ZERO:
		basis = basis.slerp(Basis.looking_at(velocity), 0.05)
	var vl := velocity * transform.basis
	if xiv_model:
		anim_tree.set("parameters/conditions/running", true)
		anim_tree.set("parameters/conditions/idle", false)
	else:
		anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / move_speed)
	move_and_slide()


func _check_if_falling() -> void:
	if is_on_floor():
		if !last_frame_floor:
			anim_tree.set("parameters/conditions/jumping", false) # TEST: needed?
			anim_tree.set("parameters/conditions/grounded", true)
			last_frame_floor = true
	# Not on floor and not jumping (e.g. walk off ledge, knock up)
	else:
		anim_state.travel("Jump_Idle")
		anim_tree.set("parameters/conditions/grounded", false)
		last_frame_floor = false


func set_parameters(new_role_key : String, new_model_scene : PackedScene, 
	spawn_position : Vector3 = Vector3.UP) -> void:
	self.name = Global.ROLE_NAMES[new_role_key] + " (Bot)"
	model_scene = new_model_scene
	role_key = new_role_key
	position = spawn_position


func move_to(other_target : Vector2) -> void:
	at_target = false
	target = Vector3(other_target.x, 0, other_target.y)


func get_arrow_vector(length: float, arrow: String) -> Vector3:
	var model_basis := transform.basis
	var arrow_vector := Vector3.ZERO
	arrow_vector.z = -1 if arrow == "up" else 1
	arrow_vector = global_position + ((model_basis * arrow_vector).normalized() * length)
	return arrow_vector


func look_at_direction(direction: Vector3) -> void:
	var look_target := (global_position.direction_to(direction) * 100) + global_position
	look_target.y = 0
	look_at(look_target)


func set_look_direction(new_look_direction : Vector3) -> void:
	look_direction = new_look_direction


func is_player() -> bool:
	return false
