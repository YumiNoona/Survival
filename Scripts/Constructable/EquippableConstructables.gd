extends EquippableItem
class_name EquippableConstructable

const M_VALID : StandardMaterial3D = preload("res://Resources/Material/M_ConstructableValid.tres")
const M_INVALID : StandardMaterial3D = preload("res://Resources/Material/M_ConstructableInValid.tres")

@onready var item_place_ray: RayCast3D = $ItemPlaceRay
@onready var constructable_area: Area3D = $ConstructableArea
@onready var constructable_area_collision_shape: CollisionShape3D = $ConstructableArea/CollisionShape3D
@onready var constructable_preview_mesh: MeshInstance3D = $ConstructableArea/ConstructablePreviewMesh

var constructable_item_key: ItemConfig.Keys
var obstacles: Array[Node3D] = []
var place_valid := false
var is_constructing := false

func _ready() -> void:
	constructable_area.rotation = Vector3.ZERO
	
	var mesh_container: Node3D = get_node_or_null("Mesh")

	if mesh_container and mesh_container.get_child_count() > 0:
		var mesh_child = mesh_container.get_child(0)
		if mesh_child is MeshInstance3D:
			constructable_preview_mesh.mesh = mesh_child.mesh.duplicate()
			constructable_area_collision_shape.shape = constructable_preview_mesh.mesh.create_convex_shape()
			set_preview_material(M_INVALID)


func set_preview_material(material: StandardMaterial3D) -> void:
	for i in constructable_preview_mesh.mesh.get_surface_count():
		constructable_preview_mesh.set_surface_override_material(i, material)


func _process(_delta: float) -> void:
	constructable_area.global_rotation.y = global_rotation.y + PI
	set_valid(check_build_validity())


func set_valid(valid: bool) -> void:
	if place_valid == valid:
		return
	
	set_preview_material(M_VALID if valid else M_INVALID)
	place_valid = valid


func check_build_validity() -> bool:
	if item_place_ray.is_colliding():
		constructable_area.global_position = item_place_ray.get_collision_point()
		
		if obstacles.is_empty():
			return true
		
		return false
	
	constructable_area.global_position = item_place_ray.to_global(item_place_ray.target_position)
	return false

func try_to_construct() -> void:
	if not place_valid:
		return
	
	EventSystem.EQU_delete_equipped_item.emit()
	constructable_area.hide()
	set_process(false)
	EventSystem.SPA_spawn_scene.emit(
		ItemConfig.get_constructable_scene(constructable_item_key),constructable_area.global_transform,true)
	
	is_constructing = true

	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.Build)





func destroy_self() -> void:
	if not is_constructing:
		return

	EventSystem.EQU_unequip_item.emit()

func _on_constructable_area_body_entered(body: Node3D) -> void:
	obstacles.append(body)

func _on_constructable_area_body_exited(body: Node3D) -> void:
	obstacles.erase(body)
