extends Node

const SAVE_PATH = "user://savegame.tres"

var save_data: GameSaveResource = null

func _ready() -> void:
	if save_file_exists():
		load_save_data()

func save_file_exists() -> bool:
	var exists = FileAccess.file_exists(SAVE_PATH)
	return exists

func create_save_data() -> GameSaveResource:
	save_data = GameSaveResource.new()
	return save_data

func save_game() -> bool:
	if not save_data:
		save_data = GameSaveResource.new()
	_collect_game_data()
	save_data.save_timestamp = int(Time.get_unix_time_from_system())
	var error = ResourceSaver.save(save_data, SAVE_PATH)
	if error != OK:
		push_error("SaveSystem: Failed to save game: Error code " + str(error))
		push_error("SaveSystem: Save path: " + SAVE_PATH)
		return false
	return true

func load_game() -> bool:
	if not save_file_exists():
		push_error("No save file found!")
		return false
	save_data = ResourceLoader.load(SAVE_PATH, "GameSaveResource")
	if not save_data:
		push_error("Failed to load save file!")
		return false
	return true

func load_save_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		save_data = ResourceLoader.load(SAVE_PATH, "GameSaveResource")

func delete_save() -> bool:
	if save_file_exists():
		var dir = DirAccess.open("user://")
		if dir:
			var error = dir.remove(SAVE_PATH.get_file())
			if error == OK:
				save_data = null
				return true
	return false

func _collect_game_data() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var stats_manager = player.get_node_or_null("Managers/PlayerStatsManager")
		if stats_manager:
			save_data.max_health = stats_manager.MAX_HEALTH
			save_data.max_energy = stats_manager.MAX_ENERGY
			save_data.max_hunger = stats_manager.MAX_HUNGER
			save_data.current_health = stats_manager.current_health
			save_data.current_energy = stats_manager.current_energy
			save_data.current_hunger = stats_manager.current_hunger
		save_data.player_position = player.global_position
		save_data.player_rotation_y = player.rotation.y
		var inv_manager = player.get_node_or_null("Managers/InventoryManager")
		if inv_manager:
			save_data.inventory = inv_manager.inventory.duplicate()
			save_data.hotbar = inv_manager.hotbar.duplicate()
			save_data.current_inventory_size = inv_manager.current_inventory_size
	
	if has_node("/root/XPManager"):
		var xp_manager = get_node("/root/XPManager")
		if xp_manager:
			save_data.total_xp = xp_manager.total_xp
			save_data.available_xp = xp_manager.available_xp
	
	if has_node("/root/LevelManager"):
		var level_manager = get_node("/root/LevelManager")
		save_data.current_level = level_manager.current_level
	
	if has_node("/root/SkillTreeManager"):
		var skill_manager = get_node("/root/SkillTreeManager")
		if skill_manager:
			save_data.unlocked_skills = skill_manager.unlocked_skills.duplicate()
	
	if has_node("/root/MissionManager"):
		var mission_manager = get_node("/root/MissionManager")
		if mission_manager:
			var active_keys: Array[String] = []
			for key in mission_manager.active_missions.keys():
				active_keys.append(String(key))
			save_data.active_missions = active_keys
			save_data.completed_missions = mission_manager.completed_missions.duplicate()
			save_data.mission_progress = {}
			for key in mission_manager.mission_progress.keys():
				var progress = mission_manager.mission_progress[key]
				if progress is Dictionary:
					save_data.mission_progress[String(key)] = progress.duplicate(true)
	
	if has_node("/root/DayTimerManager"):
		var time_manager = get_node("/root/DayTimerManager")
		save_data.current_hour = time_manager.current_hour
		save_data.current_day = time_manager.current_day

func apply_game_data_when_ready() -> void:
	if not save_data:
		return
	_apply_game_data()

func _apply_game_data() -> void:
	if not save_data:
		return
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		var stats_manager = player.get_node_or_null("Managers/PlayerStatsManager")
		if stats_manager:
			stats_manager.MAX_HEALTH = save_data.max_health
			stats_manager.MAX_ENERGY = save_data.max_energy
			stats_manager.MAX_HUNGER = save_data.max_hunger
			stats_manager.current_health = save_data.current_health
			stats_manager.current_energy = save_data.current_energy
			stats_manager.current_hunger = save_data.current_hunger
			EventSystem.PLA_health_updated.emit(stats_manager.MAX_HEALTH, stats_manager.current_health)
			EventSystem.PLA_energy_updated.emit(stats_manager.MAX_ENERGY, stats_manager.current_energy)
			EventSystem.PLA_hunger_updated.emit(stats_manager.MAX_HUNGER, stats_manager.current_hunger)
		var inv_manager = player.get_node_or_null("Managers/InventoryManager")
		if inv_manager:
			inv_manager.inventory = save_data.inventory.duplicate()
			inv_manager.hotbar = save_data.hotbar.duplicate()
			inv_manager.current_inventory_size = save_data.current_inventory_size
			call_deferred("_send_inventory_updates", inv_manager)
	
	if has_node("/root/XPManager"):
		var xp_manager = get_node("/root/XPManager")
		if xp_manager:
			xp_manager.total_xp = save_data.total_xp
			xp_manager.available_xp = save_data.available_xp
			EventSystem.XP_xp_updated.emit(xp_manager.available_xp, xp_manager.total_xp)
	
	if has_node("/root/SkillTreeManager"):
		var skill_manager = get_node("/root/SkillTreeManager")
		if skill_manager:
			skill_manager.unlocked_skills = save_data.unlocked_skills.duplicate()
			for skill_key in skill_manager.unlocked_skills.keys():
				var level = skill_manager.unlocked_skills[skill_key]
				var skill = SkillConfig.get_skill_resource(skill_key)
				if skill:
					for lvl in range(1, level + 1):
						skill_manager.apply_skill_effect(skill, lvl)
					EventSystem.SKL_skill_unlocked.emit(skill_key)
	
	if has_node("/root/MissionManager"):
		var mm = get_node("/root/MissionManager")
		if mm:
			mm.active_missions.clear()
			mm.completed_missions = save_data.completed_missions.duplicate()
			mm.mission_progress = {}
			for key in save_data.mission_progress.keys():
				var progress = save_data.mission_progress[key]
				if progress is Dictionary:
					mm.mission_progress[String(key)] = progress.duplicate(true)
			for mission_key in save_data.active_missions:
				var mission = MissionConfig.get_mission_resource(mission_key)
				if mission:
					mm.active_missions[mission_key] = mission
					if not mm.mission_progress.has(mission_key):
						mm._initialize_mission_progress(mission)
			call_deferred("_emit_mission_updates", mm)
	
	if has_node("/root/DayTimerManager"):
		var time_manager = get_node("/root/DayTimerManager")
		time_manager.set_time(save_data.current_hour, save_data.current_day)

func _send_inventory_updates(inv_manager) -> void:
	if inv_manager and is_instance_valid(inv_manager):
		inv_manager.send_inventory()
		inv_manager.send_hotbar()

func _emit_mission_updates(mission_manager) -> void:
	if mission_manager and is_instance_valid(mission_manager):
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			var inv_manager = player.get_node_or_null("Managers/InventoryManager")
			if inv_manager:
				inv_manager.send_inventory()

func apply_player_position() -> void:
	if not save_data:
		return
	var player = get_tree().get_first_node_in_group("Player")
	if player and save_data.player_position != Vector3.ZERO:
		player.global_position = save_data.player_position
		player.rotation.y = save_data.player_rotation_y
		if player.has_method("set_freeze"):
			player.set_freeze(false)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
