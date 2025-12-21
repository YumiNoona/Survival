extends Node

var current_level: int = 1
var total_xp: int = 0
var xp_for_next_level: int = 0

const BASE_XP_REQUIRED: int = 100 
const XP_MULTIPLIER: float = 1.5   

const MAX_MISSION_LEVEL: int = 16
const MAX_LEVEL: int = 20

func _enter_tree() -> void:
	EventSystem.XP_xp_updated.connect(_on_xp_updated)
	EventSystem.MIS_mission_completed.connect(_on_mission_completed)

func _ready() -> void:
	call_deferred("_initialize_from_xp_manager")

func _initialize_from_xp_manager() -> void:
	if has_node("/root/XPManager"):
		var xp_manager = get_node("/root/XPManager")
		total_xp = xp_manager.total_xp
		if current_level >= MAX_MISSION_LEVEL:
			_update_level_from_xp()

func _on_xp_updated(_available: int, total: int) -> void:
	total_xp = total
	if current_level >= MAX_MISSION_LEVEL:
		var old_level = current_level
		_update_level_from_xp()
		if current_level > old_level:
			EventSystem.LEV_level_up.emit(current_level, old_level)

func _update_level_from_xp() -> void:
	if current_level < MAX_MISSION_LEVEL:
		return
	
	var level = MAX_MISSION_LEVEL
	var xp_needed = BASE_XP_REQUIRED
	var xp_accumulated = 0
	while xp_accumulated + xp_needed <= total_xp and level < MAX_LEVEL:
		xp_accumulated += xp_needed
		level += 1
		xp_needed = int(BASE_XP_REQUIRED * pow(XP_MULTIPLIER, level - MAX_MISSION_LEVEL))
	
	current_level = min(level, MAX_LEVEL)
	if current_level < MAX_LEVEL:
		xp_for_next_level = xp_needed - (total_xp - xp_accumulated)
	else:
		xp_for_next_level = 0
	
	EventSystem.LEV_level_updated.emit(current_level, xp_for_next_level, total_xp)

func _on_mission_completed(_mission_key: String, _mission: MissionResource) -> void:
	if current_level < MAX_MISSION_LEVEL:
		var old_level = current_level
		current_level += 1
		current_level = min(current_level, MAX_MISSION_LEVEL)
		
		if current_level > old_level:
			EventSystem.LEV_level_up.emit(current_level, old_level)
			EventSystem.LEV_level_updated.emit(current_level, xp_for_next_level, total_xp)

func get_level() -> int:
	return current_level

func get_xp_for_next_level() -> int:
	return xp_for_next_level
