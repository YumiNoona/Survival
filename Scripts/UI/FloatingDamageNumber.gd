extends Node3D
class_name FloatingDamageNumber

@onready var label: Label3D = $Label3D


const LIFE_TIME := 0.85
const RISE_DISTANCE := 0.18 
const START_SCALE := 0.35
const PEAK_SCALE := 0.55
const END_SCALE := 0.40

var pool_manager: Node
var damage_value: float = 0.0
var tween: Tween

func _ready() -> void:
	pool_manager = get_node_or_null("../../DamageNumberPool") 
	if not pool_manager:
		pool_manager = get_tree().get_first_node_in_group("DamageNumberPool")
	if not pool_manager:
		var spawner = get_tree().get_first_node_in_group("Spawner")
		if spawner:
			pool_manager = spawner.get_node_or_null("DamageNumberPool")

func show_damage(damage: float, spawn_position: Vector3) -> void:
	damage_value = damage
	label.text = str(int(damage))
	global_position = spawn_position + Vector3(
		randf_range(-0.03, 0.03),
		randf_range(0.02, 0.05),
		randf_range(-0.03, 0.03)
	)
	label.modulate.a = 0.0
	label.scale = Vector3.ONE * START_SCALE
	_animate_apex_style()

func _animate_apex_style() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	
	var start_pos = global_position
	var end_pos = start_pos + Vector3(0, RISE_DISTANCE, 0)
	tween.tween_property(self, "global_position", end_pos, LIFE_TIME)
	tween.tween_property(label, "modulate:a", 1.0, 0.08)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.25)
	tween.tween_property(label, "scale", Vector3.ONE * PEAK_SCALE, 0.1)
	tween.tween_property(label, "scale", Vector3.ONE * END_SCALE, 0.45).set_delay(0.1)
	tween.tween_callback(_return_to_pool).set_delay(LIFE_TIME)

func _return_to_pool() -> void:
	if tween:
		tween.kill()
		tween = null
	
	if pool_manager:
		pool_manager.return_to_pool(self)
	else:
		visible = false
		set_process_mode(Node.PROCESS_MODE_DISABLED)
