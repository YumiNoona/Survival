extends Node3D

@export var attributes: HittableObjectAttributes
@export var residue: StaticBody3D

@onready var item_spawn_points: Node3D = $ItemSpawnPoints

var current_health: float

func _ready() -> void:
	current_health = attributes.max_health
	
	if residue != null:
		remove_child(residue)

func register_hit(weapon_resource: WeaponResource) -> void:
	if not attributes.weapon_filter.is_empty() \
	and not weapon_resource.item_key in attributes.weapon_filter:
		return

	current_health -= weapon_resource.damage

	if current_health <= 0:
		die()

func die() -> void:
	var scene_to_spawn = ItemConfig.get_pickuppable_item(attributes.drop_item_key)

	for marker in item_spawn_points.get_children():
		EventSystem.SPA_spawn_scene.emit(scene_to_spawn, marker.global_transform)


	if residue == null:
		queue_free()
		return

	for child in get_children():
		child.queue_free()

	add_child(residue)
