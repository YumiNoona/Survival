extends Node


var current_level: int = 1
var total_xp: int = 0
var xp_for_next_level: int = 0

const BASE_XP_REQUIRED: int = 100 
const XP_MULTIPLIER: float = 1.5   

func _enter_tree() -> void:
	EventSystem.XP_xp_updated.connect(_on_xp_updated)

func _ready() -> void:
	call_deferred("_initialize_from_xp_manager")

func _initialize_from_xp_manager() -> void:
	if has_node("/root/XPManager"):
		var xp_manager = get_node("/root/XPManager")
		total_xp = xp_manager.total_xp
		_update_level()

func _on_xp_updated(_available: int, total: int) -> void:
	var old_level = current_level
	total_xp = total
	_update_level()


	if current_level > old_level:
		EventSystem.LEV_level_up.emit(current_level, old_level)

func _update_level() -> void:
	var level = 1
	var xp_needed = BASE_XP_REQUIRED
	var xp_accumulated = 0
	while xp_accumulated + xp_needed <= total_xp:
		xp_accumulated += xp_needed
		level += 1
		xp_needed = int(BASE_XP_REQUIRED * pow(XP_MULTIPLIER, level - 1))
	
	current_level = level
	xp_for_next_level = xp_needed - (total_xp - xp_accumulated)
	
	EventSystem.LEV_level_updated.emit(current_level, xp_for_next_level, total_xp)

func get_level() -> int:
	return current_level

func get_xp_for_next_level() -> int:
	return xp_for_next_level
