extends Node3D

@onready var items: Node3D = $Items
@onready var damage_number_pool: Node = $DamageNumberPool
@export var constructable_holder: Node3D


func _enter_tree() -> void:
	EventSystem.SPA_spawn_scene.connect(spawn_scene)
	EventSystem.SPA_spawn_vfx.connect(spawn_vfx)
	EventSystem.SPA_spawn_damage_number.connect(spawn_damage_number)


func spawn_scene(scene:PackedScene, tform:Transform3D, is_constructable := false) -> void:
	var object := scene.instantiate()
	object.global_transform = tform
	
	if is_constructable:
		constructable_holder.add_child(object)
		EventSystem.GAM_update_navmesh.emit()
	
	else:
		items.add_child(object)


func spawn_vfx(scene:PackedScene, tform:Transform3D) -> void:
	var vfx := scene.instantiate()
	vfx.global_transform = tform
	add_child(vfx)
	
	if vfx is GPUParticles3D:
		vfx.emitting = true
	
	get_tree().create_timer(2.0, false).timeout.connect(vfx.queue_free)

func spawn_damage_number(damage: float, spawn_position: Vector3) -> void:
	if damage_number_pool:
		damage_number_pool.spawn_damage_number(damage, spawn_position)
	else:
		# Fallback if pool not found
		push_warning("DamageNumberPool not found in Spawner!")
