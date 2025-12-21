extends Node3D
class_name EquippableItem

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_holder: Node3D = get_node_or_null("MeshHolder")
@onready var mesh: Node3D = get_node_or_null("Mesh")

func _ready() -> void:
	if mesh_holder:
		for child in mesh_holder.get_children():
			if child is VisualInstance3D:
				child.layers = 2
	call_deferred("_set_initial_position_from_animation")

func _set_initial_position_from_animation() -> void:
	if not animation_player.has_animation("Swing"):
		return
	
	if not mesh:
		return
	
	var swing_animation = animation_player.get_animation("Swing")
	if not swing_animation:
		return

	var mesh_child: Node3D = null
	for child in mesh.get_children():
		if child is Node3D:
			mesh_child = child
			break
	
	if not mesh_child:
		return

	var position_track_idx = -1
	var rotation_track_idx = -1
	var mesh_path = "Mesh/" + mesh_child.name + ":"
	
	for i in range(swing_animation.get_track_count()):
		var track_path = swing_animation.track_get_path(i)
		if str(track_path).contains(mesh_path + "position"):
			position_track_idx = i
		elif str(track_path).contains(mesh_path + "rotation"):
			rotation_track_idx = i
	

	if position_track_idx >= 0:
		var key_count = swing_animation.track_get_key_count(position_track_idx)
		if key_count > 0:
			var first_position = swing_animation.track_get_key_value(position_track_idx, 0)
			if first_position is Vector3:
				mesh_child.position = first_position
	

	if rotation_track_idx >= 0:
		var key_count = swing_animation.track_get_key_count(rotation_track_idx)
		if key_count > 0:
			var first_rotation = swing_animation.track_get_key_value(rotation_track_idx, 0)
			if first_rotation is Vector3:
				mesh_child.rotation = first_rotation

func try_to_use() -> void:
	if animation_player.is_playing():
		return

	animation_player.play("Swing")
