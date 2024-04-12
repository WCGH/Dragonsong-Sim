extends Label

var player: Player


func _ready() -> void:
	GameEvents.party_ready.connect(on_party_ready)
	if !visible:
		set_process(false)


func _process(_delta: float) -> void:
	if !player:
		return
	var model_rotation: float = rad_to_deg(player.get_model_rotation().y)
	self.text = str("%.2f" % player.position.x, ", ", "%.2f" % player.position.z,
		"\nAngle: %f" % (fposmod((model_rotation + 180), 360)))


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _on_visibility_changed() -> void:
	if visible:
		set_process(true)
