extends Node

# Tracks current player stats for skill preview
# This is a read-only tracker that monitors stat changes

var current_max_health: float = 100.0
var current_max_energy: float = 100.0
var current_movement_speed_modifier: float = 1.0
var current_attack_damage_modifier: float = 1.0
var current_inventory_slots: int = 28
var has_double_jump: bool = false

func _enter_tree() -> void:
	EventSystem.PLA_increase_max_health.connect(_on_health_increased)
	EventSystem.PLA_increase_max_energy.connect(_on_energy_increased)
	EventSystem.PLA_increase_movement_speed.connect(_on_speed_increased)
	EventSystem.PLA_increase_attack_damage.connect(_on_attack_damage_increased)
	EventSystem.PLA_enable_double_jump.connect(_on_double_jump_enabled)
	EventSystem.INV_add_inventory_slots.connect(_on_inventory_slots_added)

func _ready() -> void:
	# Wait a frame for all nodes to be ready
	await get_tree().process_frame
	_update_initial_stats()

func _update_initial_stats() -> void:
	# Get initial stats from PlayerStatsManager (accessed via Player node)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var stats_manager = player.get_node_or_null("Managers/PlayerStatsManager")
		if stats_manager:
			current_max_health = stats_manager.MAX_HEALTH
			current_max_energy = stats_manager.MAX_ENERGY
		
		# Get initial inventory size (also via Player node)
		var inv_manager = player.get_node_or_null("Managers/InventoryManager")
		if inv_manager:
			current_inventory_slots = inv_manager.current_inventory_size
		
		# Get initial movement speed modifier from Player
		current_movement_speed_modifier = player.speed_modifier
		has_double_jump = player.can_double_jump
	
	# Attack damage modifier starts at 1.0 (100%), skills will increase it via signals
	# We track it through PLA_increase_attack_damage signals

func _on_health_increased(amount: int) -> void:
	current_max_health += amount

func _on_energy_increased(amount: int) -> void:
	current_max_energy += amount

func _on_speed_increased(percentage: int) -> void:
	current_movement_speed_modifier += percentage / 100.0

func _on_attack_damage_increased(percentage: int) -> void:
	current_attack_damage_modifier += percentage / 100.0

func _on_double_jump_enabled() -> void:
	has_double_jump = true

func _on_inventory_slots_added(amount: int) -> void:
	current_inventory_slots += amount

func get_current_stats() -> Dictionary:
	return {
		"max_health": current_max_health,
		"max_energy": current_max_energy,
		"movement_speed_modifier": current_movement_speed_modifier,
		"attack_damage_modifier": current_attack_damage_modifier,
		"inventory_slots": current_inventory_slots,
		"has_double_jump": has_double_jump
	}

func calculate_stats_after_skill(skill: SkillResource, level: int) -> Dictionary:
	var current = get_current_stats()
	var future = current.duplicate()
	
	var value = SkillTreeManager.get_value_for_level(skill, level)
	
	match skill.unlock_type:
		SkillResource.UnlockType.HEALTH_BONUS:
			future["max_health"] = current["max_health"] + value
		SkillResource.UnlockType.ENERGY_BONUS:
			future["max_energy"] = current["max_energy"] + value
		SkillResource.UnlockType.MOVEMENT_SPEED:
			future["movement_speed_modifier"] = current["movement_speed_modifier"] + (value / 100.0)
		SkillResource.UnlockType.ATTACK_DAMAGE:
			future["attack_damage_modifier"] = current["attack_damage_modifier"] + (value / 100.0)
		SkillResource.UnlockType.INVENTORY_SLOTS:
			future["inventory_slots"] = current["inventory_slots"] + value
		SkillResource.UnlockType.DOUBLE_JUMP:
			if level == 1:
				future["has_double_jump"] = true
	
	return future
