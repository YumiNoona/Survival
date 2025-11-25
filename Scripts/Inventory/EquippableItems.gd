extends Node3D
class_name EquippableItem

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_holder: Node3D = get_node_or_null("MeshHolder")

func _ready() -> void:
	if not mesh_holder:
		return

	for child in mesh_holder.get_children():
		if child is VisualInstance3D:
			child.layers = 2



func try_to_use() -> void:
	if animation_player.is_playing():
		return

	animation_player.play("Swing")
