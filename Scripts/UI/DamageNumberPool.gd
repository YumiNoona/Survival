extends Node
class_name DamageNumberPool

# Pool configuration
@export var pool_size: int = 50
@export var pre_warm: bool = true

# Pre-cached resources
var damage_number_scene: PackedScene
var available_pool: Array[Node3D] = []
var active_pool: Array[Node3D] = []

# Font pre-warming
var pre_warmed: bool = false

func _ready() -> void:
	damage_number_scene = load("res://Scenes/UI/FloatingDamageNumber.tscn")
	
	if pre_warm:
		_pre_warm_pool()
		_pre_cache_font()

func _pre_warm_pool() -> void:
	# Pre-instantiate all damage numbers
	for i in range(pool_size):
		var damage_number = damage_number_scene.instantiate()
		damage_number.visible = false
		damage_number.set_process_mode(Node.PROCESS_MODE_DISABLED)
		add_child(damage_number)
		available_pool.append(damage_number)
	
	pre_warmed = true

func _pre_cache_font() -> void:
	# Pre-render digits 0-9 to cache glyphs
	# Use one of the pooled damage numbers to pre-warm font rendering
	if available_pool.size() > 0:
		var temp_number = available_pool[0]
		if temp_number.has_node("Label3D"):
			var label = temp_number.get_node("Label3D")
			# Pre-render all digits
			label.text = "0123456789"
			temp_number.visible = true
			# Force render for 2 frames to cache glyphs
			await get_tree().process_frame
			await get_tree().process_frame
			temp_number.visible = false

func spawn_damage_number(damage: float, spawn_position: Vector3) -> void:
	var damage_number: Node3D = null
	
	# Get from pool or create new if pool exhausted
	if available_pool.size() > 0:
		damage_number = available_pool.pop_back()
	else:
		# Fallback: create new (shouldn't happen if pool is sized correctly)
		damage_number = damage_number_scene.instantiate()
		add_child(damage_number)
	
	# Activate the damage number
	active_pool.append(damage_number)
	damage_number.visible = true
	damage_number.set_process_mode(Node.PROCESS_MODE_INHERIT)
	
	# Initialize and animate
	if damage_number.has_method("show_damage"):
		damage_number.show_damage(damage, spawn_position)

func return_to_pool(damage_number: Node3D) -> void:
	if damage_number in active_pool:
		active_pool.erase(damage_number)
	
	# Kill any active tweens
	if damage_number.has_method("_return_to_pool"):
		# Already handled in FloatingDamageNumber
		pass
	
	# Reset state
	damage_number.visible = false
	damage_number.set_process_mode(Node.PROCESS_MODE_DISABLED)
	damage_number.global_position = Vector3.ZERO
	
	# Reset label state
	if damage_number.has_node("Label3D"):
		var label = damage_number.get_node("Label3D")
		label.modulate.a = 1.0
		label.scale = Vector3.ONE * 0.35  # Reset to START_SCALE
	
	# Return to available pool
	if damage_number not in available_pool:
		available_pool.append(damage_number)
