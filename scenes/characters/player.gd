# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Player Controller
## Instantiate alongside set_parameters.

extends PlayableCharacter
class_name Player

signal target_changed(target: Node3D)

const MAX_MOUSE_CLICK_MOVEMENT := 3000.0

var debug := false
@export var move_speed : float = 14.3
@export var acceleration : float = 20.0
@export var jump_force : float = 10.0
@export var gravity : float = 30.0
@export var player_scale : float = 1.25
@export var camera_distance : float = 20.0
@export var camera_max_dist : float = 30.0
@export_range(0, 1) var camera_zoom_speed : float = 0.5
@export var dash_distance := 15.0
@export var dash_duration := 0.5
@export var sprint_duration := 10.0
@export var arms_length_duration := 6.0
@export var model_scene : PackedScene

var debuffs := []
var facing_angle : float
var rotation_speed := 0.15
var click_rotation_speed := 0.3
var mouse_sensitivity := 0.002
var twist_input := 0.0
var pitch_input := 0.0
var mouse_position := Vector2(950.0, 480.0)
var mouse_travel := Vector2.ZERO
# Movement
var rotation_offset := 0.0
var target_rotation := 0.0
var xiv_model: bool
var sprinting := false
var jumping := false
var idle := true
var strafe_left := false
var strafe_right := false
var running := false
var last_input_back := false
var is_frozen := false

@onready var twist_pivot : Node3D = %TwistPivot
@onready var pitch_pivot : Node3D = %PitchPivot
@onready var camera : Camera3D = %Camera3D
@onready var camera_spring_arm : SpringArm3D = %SpringArm3D
@onready var coords_label : Label = get_tree().get_first_node_in_group("coords_label")
@onready var debuff_container : BoxContainer = get_tree().get_first_node_in_group("debuff_container")


func _ready() -> void:
	model = model_scene.instantiate()
	add_child(model)
	xiv_model = model.get_meta("xiv_model", false)
	model.scale = Vector3.ONE * player_scale
	anim_tree = model.get_node("AnimationTree")
	anim_state = model.get_node("AnimationTree").get("parameters/playback")
	camera_distance = SavedVariables.save_data["settings"]["camera_distance"]
	camera_spring_arm.spring_length = camera_distance


func set_parameters(new_role_key : String, new_model_scene : PackedScene, 
	spawn_position : Vector3) -> void:
	model_scene = new_model_scene
	role_key = new_role_key
	position = spawn_position


func _physics_process(delta : float) -> void:
	if model == null:
		return
	
	# Reset scene if player is out of bounds.
	if global_position.y < -7 : 
		print("Player out of bounds.")
		get_tree().reload_current_scene()
	
	# Rotate pivot to match camera.
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	twist_input = 0.0
	pitch_input = 0.0
	
	# Apply gravity if not on floor.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# TODO: clean up animations when frozen.
	if is_frozen:
		return
	
	# 3D Movement (camera relative).
	# Handle left+right click movement
	if Input.is_action_pressed("right_click") and Input.is_action_pressed("left_click"):
		Input.action_press("move_forward")
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if xiv_model:
		idle = input == Vector2(0, 0)  # TODO: is this needed?
		anim_tree.set("parameters/conditions/idle", idle)
		strafe_left = input == Vector2(-1, 0)
		anim_tree.set("parameters/conditions/strafe_left", strafe_left)
		strafe_right = input == Vector2(1, 0)
		anim_tree.set("parameters/conditions/strafe_right", strafe_right)
		running = input.y != 0
		anim_tree.set("parameters/conditions/running", running)
		last_input_back = input == Vector2(0, 1) or input == Vector2(0, 0)
		# Run backward
		if input == Vector2(0, 1):
			rotation_offset = 180
		# Forward strafe
		elif input.y < 0 and input.y > -1.0:
			rotation_offset = -63.65 * input.x
		# Back strafe
		elif input.y > 0 and input.y < 1.0:
			rotation_offset = -190.95 * input.x
		elif !last_input_back:
			rotation_offset = 0.0
	
	var dir := (twist_pivot.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if is_on_floor() and !sliding:
		var xz_acel := acceleration if input.x != 0 else 20.0
		velocity.x = lerp(velocity.x, dir.x * move_speed, xz_acel * delta)
		xz_acel = acceleration if input.y != 0 else 20.0
		velocity.z = lerp(velocity.z, dir.z * move_speed, xz_acel * delta)
	var vl := velocity * twist_pivot.transform.basis
	
	if !xiv_model:
		anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / move_speed)
	
	if is_inside_tree():
		move_and_slide()
	
	# Debug: update coordinates label
	# TODO: move to own script
	if coords_label != null:
		var model_rotation: float = rad_to_deg(get_model_rotation().y)
		coords_label.text = str("%.2f" % position.x, ", ", "%.2f" % position.z,
			"\nAngle: %f" % (fposmod((model_rotation + 180), 360)))
	
	# Rotate model to match pivot.
	if (Input.is_action_pressed("right_click") and Input.is_action_pressed("left_click")) or\
		(Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")):
		model.rotation.y = twist_pivot.rotation.y
	if !idle:
		target_rotation = twist_pivot.rotation.y + deg_to_rad(rotation_offset)
	model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed)
	
	# Jumping.
	if is_on_floor():
		if Input.is_action_pressed("jump") and last_frame_floor:
			velocity.y = jump_force
			jumping = true
			anim_tree.set("parameters/conditions/jumping", true)
			set_grounded(false)
		elif not last_frame_floor:
			jumping = false
			anim_tree.set("parameters/conditions/jumping", false)
			set_grounded(true)
		last_frame_floor = true
	# Not on floor and not jumping (e.g. walk off ledge, knock up)
	else: 
		if not jumping:
			anim_state.travel("Jump_Idle")
			set_grounded(false)
		last_frame_floor = false
	
	# Release forward if not pressing W.
	if Input.is_action_pressed("right_click") and Input.is_action_pressed("left_click")\
		and !Input.is_key_pressed(KEY_W):
		Input.action_release("move_forward")


func set_grounded(grounded: bool) -> void:
	if grounded:
		if xiv_model and running:
			anim_tree.set("parameters/conditions/grounded_run", true)
		elif xiv_model and strafe_left:
			anim_tree.set("parameters/conditions/grounded_strafe_left", true)
		elif xiv_model and strafe_right:
			anim_tree.set("parameters/conditions/grounded_strafe_right", true)
		else: # Idle or old model.
			anim_tree.set("parameters/conditions/grounded", true)
	else:
		if xiv_model:
				anim_tree.set("parameters/conditions/grounded_run", false)
				anim_tree.set("parameters/conditions/grounded_strafe_left", false)
				anim_tree.set("parameters/conditions/grounded_strafe_right", false)
		anim_tree.set("parameters/conditions/grounded", false)


# Mouse event handling
func _unhandled_input(event : InputEvent) -> void:
	# Mouse motion.
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
			# Get left click movement to exclude click/drags
			mouse_travel += event.relative
	# Mouse button pressed.
	if event is InputEventMouseButton:
		# Left/Right click.
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				mouse_position = event.global_position
				if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				if !(Input.is_action_pressed("left_click") or Input.is_action_pressed("right_click")):
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					Input.warp_mouse(mouse_position)
					if event.button_index == MOUSE_BUTTON_LEFT and\
						mouse_travel.length_squared() < MAX_MOUSE_CLICK_MOVEMENT:
						handle_left_click(mouse_position)
					Input.warp_mouse(mouse_position) # Duplicate call to counter mouse warp bug (shruge).
					mouse_travel = Vector2.ZERO
					twist_input = 0.0
					pitch_input = 0.0
		# Scroll wheel up/down (camera zoom).
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_spring_arm.spring_length = max(0.1, camera.position.z - camera_zoom_speed)
			camera_distance = camera_spring_arm.spring_length
			SavedVariables.save_data["settings"]["camera_distance"] = camera_distance
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_spring_arm.spring_length = min(camera_max_dist, camera.position.z + camera_zoom_speed)
			camera_distance = camera_spring_arm.spring_length
			SavedVariables.save_data["settings"]["camera_distance"] = camera_distance


func handle_left_click(mouse_pos: Vector2) -> void:
	var ray_result: Dictionary = camera.get_first_ray_collision(mouse_pos)
	if debug:
		print(mouse_pos)
		print(ray_result)
	if ray_result.is_empty():
		target_changed.emit(null)
		return
	var collider: Node3D = ray_result["collider"]
	if collider is Area3D:
		collider = collider.get_parent_node_3d()
	target_changed.emit(collider)


func get_model_rotation() -> Vector3:
	return self.model.rotation


func move_to(vec2 : Vector2) -> void:
	if debug:
		print("Error. Script tried to move player to: ", vec2)
	return


func get_arrow_vector(length: float, arrow: String) -> Vector3:
	var arrow_vector := Vector3.ZERO
	arrow_vector.z = -1 if arrow == "up" else 1
	return global_position + ((model.transform.basis * arrow_vector).normalized() * length)


func set_look_direction(_new_look_direction : Vector3) -> void:
	return


func freeze_player() -> void:
	is_frozen = true


func unfreeze_player() -> void:
	is_frozen = false


func is_player() -> bool:
	return true


func dash() -> void:
	#var dir : Vector3 = twist_pivot.global_transform.basis.z.normalized()
	var tar : Vector3 = (twist_pivot.global_transform.basis.z.normalized() * -dash_distance) 
	tar += global_position
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position",
		tar, dash_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# TODO: Add debuff
func arms_length() -> void:
	kb_resist = true
	var timer: Timer = Timer.new()
	timer.wait_time = arms_length_duration
	add_child(timer)
	timer.timeout.connect(func() -> void: kb_resist = false)
	timer.start()


# TODO: Add debuff
func sprint() -> void:
	sprinting = true
	anim_tree.set("parameters/Run_Sprint/blend_position", 1.0)
	move_speed = move_speed * 1.25
	var timer: Timer = Timer.new()
	timer.wait_time = sprint_duration
	add_child(timer)
	timer.timeout.connect(func() -> void:
		sprinting = false
		move_speed = move_speed * 0.8
		anim_tree.set("parameters/Run_Sprint/blend_position", 0.0)
		timer.queue_free()
	)
	timer.start()
