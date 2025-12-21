extends Node
class_name DamageNumberPool


@export var pool_size: int = 50
@export var pre_warm: bool = true

var damage_number_scene: PackedScene
var available_pool: Array[Node3D] = []
var active_pool: Array[Node3D] = []
var pre_warmed: bool = false

func _ready() -> void:
	damage_number_scene = load("res://Scenes/UI/FloatingDamageNumber.tscn")
	
	if pre_warm:
		_pre_warm_pool()
		_pre_cache_font()

func _pre_warm_pool() -> void:
	for i in range(pool_size):
		var damage_number = damage_number_scene.instantiate()
		damage_number.visible = false
		damage_number.set_process_mode(Node.PROCESS_MODE_DISABLED)
		add_child(damage_number)
		available_pool.append(damage_number)
	
	pre_warmed = true

func _pre_cache_font() -> void:
	if available_pool.size() > 0:
		var temp_number = available_pool[0]
		if temp_number.has_node("Label3D"):
			var label = temp_number.get_node("Label3D")
			label.text = "0123456789"
			temp_number.visible = true
			await get_tree().process_frame
			await get_tree().process_frame
			temp_number.visible = false

func spawn_damage_number(damage: float, spawn_position: Vector3) -> void:
	var damage_number: Node3D = null
	

	if available_pool.size() > 0:
		damage_number = available_pool.pop_back()
	else:
		damage_number = damage_number_scene.instantiate()
		add_child(damage_number)
	active_pool.append(damage_number)
	damage_number.visible = true
	damage_number.set_process_mode(Node.PROCESS_MODE_INHERIT)


	if damage_number.has_method("show_damage"):
		damage_number.show_damage(damage, spawn_position)

func return_to_pool(damage_number: Node3D) -> void:
	if damage_number in active_pool:
		active_pool.erase(damage_number)

	if damage_number.has_method("_return_to_pool"):
		pass
	

	damage_number.visible = false
	damage_number.set_process_mode(Node.PROCESS_MODE_DISABLED)
	damage_number.global_position = Vector3.ZERO


	if damage_number.has_node("Label3D"):
		var label = damage_number.get_node("Label3D")
		label.modulate.a = 1.0
		label.scale = Vector3.ONE * 0.35


	if damage_number not in available_pool:
		available_pool.append(damage_number)
