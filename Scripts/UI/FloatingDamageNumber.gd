extends Node3D
class_name FloatingDamageNumber

@onready var label: Label3D = $Label3D

# Animation constants (Apex-accurate)
const LIFE_TIME := 0.85
const RISE_DISTANCE := 0.18  # Much smaller for FPP
const START_SCALE := 0.35
const PEAK_SCALE := 0.55
const END_SCALE := 0.40

# Pool reference
var pool_manager: Node

var damage_value: float = 0.0
var tween: Tween

func _ready() -> void:
	# Find pool manager - try multiple paths
	pool_manager = get_node_or_null("../../DamageNumberPool")  # Relative to Spawner
	if not pool_manager:
		pool_manager = get_tree().get_first_node_in_group("DamageNumberPool")
	if not pool_manager:
		# Try absolute path as fallback
		var spawner = get_tree().get_first_node_in_group("Spawner")
		if spawner:
			pool_manager = spawner.get_node_or_null("DamageNumberPool")

func show_damage(damage: float, spawn_position: Vector3) -> void:
	damage_value = damage
	
	# Set damage text
	label.text = str(int(damage))
	
	# Set starting position with tiny random offset
	global_position = spawn_position + Vector3(
		randf_range(-0.03, 0.03),
		randf_range(0.02, 0.05),
		randf_range(-0.03, 0.03)
	)
	
	# Reset visual state
	label.modulate.a = 0.0
	label.scale = Vector3.ONE * START_SCALE
	
	# Start animation
	_animate_apex_style()

func _animate_apex_style() -> void:
	# Kill any existing tween
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	
	var start_pos = global_position
	var end_pos = start_pos + Vector3(0, RISE_DISTANCE, 0)
	
	# Vertical float (no lateral movement)
	tween.tween_property(self, "global_position", end_pos, LIFE_TIME)
	
	# Alpha - fast fade in, then fade out
	tween.tween_property(label, "modulate:a", 1.0, 0.08)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.25)
	
	# Scale - small and controlled
	tween.tween_property(label, "scale", Vector3.ONE * PEAK_SCALE, 0.1)
	tween.tween_property(label, "scale", Vector3.ONE * END_SCALE, 0.45).set_delay(0.1)
	
	# Return to pool when done
	tween.tween_callback(_return_to_pool).set_delay(LIFE_TIME)

func _return_to_pool() -> void:
	# Kill any active tween
	if tween:
		tween.kill()
		tween = null
	
	if pool_manager:
		pool_manager.return_to_pool(self)
	else:
		# Fallback: just hide and disable
		visible = false
		set_process_mode(Node.PROCESS_MODE_DISABLED)
