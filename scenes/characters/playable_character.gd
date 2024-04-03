# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CharacterBody3D
class_name PlayableCharacter

@onready var party_list : PartyList = get_tree().get_first_node_in_group("party_list")

var model: Node3D
var anim_tree: AnimationTree
var rotation_anim: AnimationPlayer
var anim_state: AnimationNodeStateMachinePlayback
var last_frame_floor := true
var sliding := false
var kb_resist := false
var role_key : String


# Party list handles addition/removal of player debuffs.
# Returns debuff timeout signal.
func add_debuff(debuff_icon_scene : PackedScene, duration : float = 0.0) -> Signal:
	return party_list.add_debuff(role_key, debuff_icon_scene, duration)


# Party list handles addition/removal of player debuffs.
func remove_debuff(debuff_name: String) -> void:
	party_list.remove_debuff(role_key, debuff_name)


func get_model_rotation() -> Vector3:
	return self.rotation


func knockback(distance : float, source : Vector2) -> void:
	if kb_resist:
		return
	var target_v2 : Vector2 = source.direction_to(v2(global_position))
	target_v2 = (target_v2 * distance) + v2(global_position)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position",
		Vector3(target_v2.x, 0, target_v2.y), 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func set_active_target() -> void:
	pass


func remove_active_target() -> void:
	pass


# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
