extends Node

# Mission Manager - Tracks mission progress and completion
# Similar to Palworld's mission system

var active_missions: Dictionary = {}  # mission_key: MissionResource
var completed_missions: Array[String] = []  # Array of completed mission_key strings
var mission_progress: Dictionary = {}  # mission_key: progress_data

func _enter_tree() -> void:
	# Connect to events that track mission progress
	EventSystem.INV_inventory_updated.connect(_on_inventory_updated)
	EventSystem.MIS_item_crafted.connect(_on_item_crafted)
	EventSystem.XP_award_xp.connect(_on_xp_awarded)  # Track if XP was awarded (for debugging)

func _ready() -> void:
	# Load and activate initial missions
	_load_initial_missions()

func _load_initial_missions() -> void:
	# Load missions from MissionConfig
	var missions = MissionConfig.get_all_missions()
	for mission in missions:
		if _can_activate_mission(mission):
			activate_mission(mission)

func _can_activate_mission(mission: MissionResource) -> bool:
	# Check if prerequisites are met
	for prereq_key in mission.prerequisite_missions:
		if not prereq_key in completed_missions:
			return false
	return true

func activate_mission(mission: MissionResource) -> void:
	if active_missions.has(mission.mission_key):
		return  # Already active
	
	active_missions[mission.mission_key] = mission
	_initialize_mission_progress(mission)
	EventSystem.MIS_mission_progress_updated.emit(mission.mission_key, mission_progress[mission.mission_key])

func _initialize_mission_progress(mission: MissionResource) -> void:
	var progress_data = {}
	
	match mission.mission_type:
		MissionResource.MissionType.COLLECT_ITEMS:
			# Initialize progress for each required item
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
	# Check all active COLLECT_ITEMS missions
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
			
			# Initialize progress entry if it doesn't exist
			if not progress.has(item_id):
				progress[item_id] = {
					"required": required_amount,
					"current": 0
				}
			
			# Count how many of this item the player has (inventory stores item IDs as integers)
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
	# Check all active CRAFT_ITEM missions
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
	
	# Award XP
	EventSystem.XP_award_xp.emit(mission.xp_reward)
	
	# Mark as completed
	completed_missions.append(mission_key)
	active_missions.erase(mission_key)
	mission_progress.erase(mission_key)
	
	# Emit completion signal
	EventSystem.MIS_mission_completed.emit(mission_key, mission)
	
	# Check if any new missions can be activated
	_check_for_new_missions()

func _check_for_new_missions() -> void:
	# Reload missions and activate any that are now available
	var missions = MissionConfig.get_all_missions()
	for mission in missions:
		if not active_missions.has(mission.mission_key) and not mission.mission_key in completed_missions:
			if _can_activate_mission(mission):
				activate_mission(mission)

func _on_xp_awarded(_amount: int) -> void:
	# Debug: Can be used to track XP awards
	pass

func get_mission_progress(mission_key: String) -> Dictionary:
	if mission_progress.has(mission_key):
		return mission_progress[mission_key]
	return {}

func is_mission_completed(mission_key: String) -> bool:
	return mission_key in completed_missions

func is_mission_active(mission_key: String) -> bool:
	return active_missions.has(mission_key)
