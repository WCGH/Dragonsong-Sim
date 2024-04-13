# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer
class_name PartyList

@export var aura_container_scene : PackedScene
@export var debuff_scene : PackedScene
@export var role_icons : Dictionary

@onready var v_box_container : VBoxContainer = $MarginContainer/VBoxContainer
@onready var player_debuff_container : BoxContainer = get_tree().get_first_node_in_group("player_debuff_container")

var aura_containers : Dictionary


func create_party_list(player_role_key : String) -> void:
	# Add player first
	var player_container : HBoxContainer = aura_container_scene.instantiate()
	#var player_icon : TextureRect = player_container.get_child(0)
	var player_icon = role_icons[player_role_key].instantiate()
	var player_label : Label = player_container.get_child(0)
	player_container.add_child(player_icon)
	player_container.move_child(player_icon, 0)
	#player_icon.texture = load(role_icons[player_role_key])
	player_label.text = "You"
	v_box_container.add_child(player_container)
	aura_containers[player_role_key] = player_container.get_child(2)
	
	for key : String in Global.ROLE_KEYS:
		if key == player_role_key:
			continue
		var new_container : HBoxContainer = aura_container_scene.instantiate()
		var icon_texture = role_icons[key].instantiate()
		var label : Label = new_container.get_child(0)
		new_container.add_child(icon_texture)
		new_container.move_child(icon_texture, 0)
		#icon.texture = load(role_icons[key])
		label.text = Global.ROLE_NAMES[key]
		v_box_container.add_child(new_container)
		aura_containers[key] = new_container.get_child(2)

#
## Fully clears the party list.
#func clear_party() -> void:
	#for pc_container: HBoxContainer in v_box_container.get_children():
		#pc_container.queue_free()
	#for player_debuff in player_debuff_container.get_children():
		#player_debuff.queue_free()
	#aura_containers = {}


# Returns timeout signal
func add_debuff(role_key : String, debuff_icon_scene : PackedScene, duration : float = 0.0) -> Signal:
	var new_debuff : Debuff = debuff_scene.instantiate()
	new_debuff.set_debuff(debuff_icon_scene, role_key, duration)
	aura_containers[role_key].add_child(new_debuff)
	if role_key == Global.player_role_key:
		var player_debuff : Debuff = debuff_scene.instantiate()
		player_debuff.set_debuff(debuff_icon_scene, role_key, duration)
		player_debuff_container.add_child(player_debuff)
	return new_debuff.debuff_timeout


func remove_debuff(role_key : String, debuff_name : String) -> void:
	# Remove from party list debuffs
	var auras : Array = aura_containers[role_key].get_children()
	for aura : Node in auras:
		if aura is Debuff and aura.debuff_name == debuff_name:
			aura.queue_free()
	# Remove aura from player debuffs
	if role_key == Global.player_role_key:
		var player_debuffs : Array = player_debuff_container.get_children()
		for player_debuff : Node in player_debuffs:
			if player_debuff.debuff_name == debuff_name:
				player_debuff.queue_free()
