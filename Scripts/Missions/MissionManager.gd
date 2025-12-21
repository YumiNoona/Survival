extends Node

var active_missions: Dictionary = {} 
var completed_missions: Array[String] = []  
var mission_progress: Dictionary = {} 

func _enter_tree() -> void:
	EventSystem.INV_inventory_updated.connect(_on_inventory_updated)
	EventSystem.MIS_item_crafted.connect(_on_item_crafted)
	EventSystem.XP_award_xp.connect(_on_xp_awarded) 

func _ready() -> void:
	if not SaveSystem.save_data or SaveSystem.save_data.active_missions.is_empty():
		_load_initial_missions()

func _load_initial_missions() -> void:
	var missions = MissionConfig.get_all_missions()
	for mission in missions:
		if _can_activate_mission(mission):
			activate_mission(mission)

func _can_activate_mission(mission: MissionResource) -> bool:
	for prereq_key in mission.prerequisite_missions:
		if not prereq_key in completed_missions:
			return false
	return true

func activate_mission(mission: MissionResource) -> void:
	if active_missions.has(mission.mission_key):
		return 
	
	active_missions[mission.mission_key] = mission
	_initialize_mission_progress(mission)
	EventSystem.MIS_mission_progress_updated.emit(mission.mission_key, mission_progress[mission.mission_key])

func _initialize_mission_progress(mission: MissionResource) -> void:
	var progress_data = {}
	
	match mission.mission_type:
		MissionResource.MissionType.COLLECT_ITEMS:
			for item_req in mission.required_items:
				if item_req is MissionRequirement:
					var item_id = item_req.item_id
					var required_amount = item_req.amount
					progress_data[item_id] = {
						"required": required_amount,
						"current": 0
					}
		
		MissionResource.MissionType.CRAFT_ITEM:
			progress_data["crafted"] = false
		
		MissionResource.MissionType.KILL_ENEMY:
			progress_data["kills"] = 0
			progress_data["required"] = mission.required_kills
		
		MissionResource.MissionType.BUILD_STRUCTURE:
			progress_data["built"] = false
	
	mission_progress[mission.mission_key] = progress_data

func _on_inventory_updated(inventory: Array) -> void:
	for mission_key in active_missions.keys():
		var mission = active_missions[mission_key]
		if mission.mission_type == MissionResource.MissionType.COLLECT_ITEMS:
			_check_collect_items_progress(mission, inventory)

func _check_collect_items_progress(mission: MissionResource, inventory: Array) -> void:
	if not mission_progress.has(mission.mission_key):
		return
	
	var progress = mission_progress[mission.mission_key]
	var all_complete = true
	
	for item_req in mission.required_items:
		if item_req is MissionRequirement:
			var item_id: int = item_req.item_id
			var required_amount = item_req.amount

			if not progress.has(item_id):
				progress[item_id] = {
					"required": required_amount,
					"current": 0
				}

			var current_count = 0
			for inv_item_id in inventory:
				if inv_item_id == item_id:
					current_count += 1
			
			progress[item_id]["current"] = current_count
			
			if current_count < required_amount:
				all_complete = false
	
	mission_progress[mission.mission_key] = progress
	EventSystem.MIS_mission_progress_updated.emit(mission.mission_key, progress)
	
	if all_complete:
		_complete_mission(mission.mission_key)

func _on_item_crafted(item_key: ItemConfig.Keys) -> void:
	for mission_key in active_missions.keys():
		var mission = active_missions[mission_key]
		if mission.mission_type == MissionResource.MissionType.CRAFT_ITEM:
			if mission.required_craft_item == item_key:
				var progress = mission_progress[mission_key]
				progress["crafted"] = true
				mission_progress[mission_key] = progress
				EventSystem.MIS_mission_progress_updated.emit(mission_key, progress)
				_complete_mission(mission_key)

func _complete_mission(mission_key: String) -> void:
	if not active_missions.has(mission_key):
		return

	var mission = active_missions[mission_key]
	EventSystem.XP_award_xp.emit(mission.xp_reward)
	completed_missions.append(mission_key)
	active_missions.erase(mission_key)
	mission_progress.erase(mission_key)
	EventSystem.MIS_mission_completed.emit(mission_key, mission)
	_check_for_new_missions()

func _check_for_new_missions() -> void:
	var missions = MissionConfig.get_all_missions()
	for mission in missions:
		if not active_missions.has(mission.mission_key) and not mission.mission_key in completed_missions:
			if _can_activate_mission(mission):
				activate_mission(mission)

func _on_xp_awarded(_amount: int) -> void:
	pass

func get_mission_progress(mission_key: String) -> Dictionary:
	if mission_progress.has(mission_key):
		return mission_progress[mission_key]
	return {}

func is_mission_completed(mission_key: String) -> bool:
	return mission_key in completed_missions

func is_mission_active(mission_key: String) -> bool:
	return active_missions.has(mission_key)
