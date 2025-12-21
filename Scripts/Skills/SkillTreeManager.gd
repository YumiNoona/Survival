extends Node


var unlocked_skills: Dictionary = {} 

func _enter_tree() -> void:
	EventSystem.SKL_try_unlock_skill.connect(try_unlock_skill)
	EventSystem.SKL_is_skill_unlocked.connect(_is_skill_unlocked)
	EventSystem.SKL_get_skill_level.connect(_get_skill_level)

func is_skill_unlocked(skill_key: String) -> bool:
	return unlocked_skills.has(skill_key) and unlocked_skills[skill_key] > 0

func get_skill_level(skill_key: String) -> int:
	if unlocked_skills.has(skill_key):
		return unlocked_skills[skill_key]
	return 0

func can_unlock_skill(skill_key: String) -> bool:
	var skill = SkillConfig.get_skill_resource(skill_key)
	if not skill:
		return false
	
	var current_level = get_skill_level(skill_key)
	if current_level >= skill.max_level:
		return false


	if current_level == 0:
		for prereq_key in skill.prerequisites:
			if not is_skill_unlocked(prereq_key):
				return false


	var xp_cost = get_xp_cost_for_level(skill, current_level + 1)
	var xp_manager = XPManager
	if xp_manager.available_xp < xp_cost:
		return false
	
	return true

func get_xp_cost_for_level(skill: SkillResource, level: int) -> int:
	if skill.xp_cost_per_level > 0:
		return skill.xp_cost + ((level - 1) * skill.xp_cost_per_level)
	else:
		return skill.xp_cost

func get_value_for_level(skill: SkillResource, level: int) -> int:
	if skill.value_per_level > 0:
		return skill.unlock_value + ((level - 1) * skill.value_per_level)
	else:
		return skill.unlock_value

func try_unlock_skill(skill_key: String) -> bool:
	if not can_unlock_skill(skill_key):
		return false
	
	var skill = SkillConfig.get_skill_resource(skill_key)
	if not skill:
		return false
	
	var current_level = get_skill_level(skill_key)
	var next_level = current_level + 1
	var xp_cost = get_xp_cost_for_level(skill, next_level)
	
	# Spend XP
	if not XPManager._spend_xp(xp_cost):
		return false


	unlocked_skills[skill_key] = next_level
	

	apply_skill_effect(skill, next_level)
	EventSystem.SKL_skill_unlocked.emit(skill_key)
	return true

func apply_skill_effect(skill: SkillResource, level: int) -> void:
	var value = get_value_for_level(skill, level)
	
	match skill.unlock_type:
		SkillResource.UnlockType.INVENTORY_SLOTS:
			EventSystem.INV_add_inventory_slots.emit(value)
		
		SkillResource.UnlockType.DOUBLE_JUMP:
			if level == 1:
				EventSystem.PLA_enable_double_jump.emit()
		
		SkillResource.UnlockType.WEAPON_TIER:
			EventSystem.CRAFT_unlock_weapon_tier.emit(value)
		
		SkillResource.UnlockType.CRAFTING_RECIPE:
			if level == 1:
				EventSystem.CRAFT_unlock_recipe.emit(skill.unlock_data)
		
		SkillResource.UnlockType.MOVEMENT_SPEED:
			EventSystem.PLA_increase_movement_speed.emit(value)
		
		SkillResource.UnlockType.HEALTH_BONUS:
			EventSystem.PLA_increase_max_health.emit(value)
		
		SkillResource.UnlockType.ENERGY_BONUS:
			EventSystem.PLA_increase_max_energy.emit(value)
		
		SkillResource.UnlockType.ATTACK_DAMAGE:
			EventSystem.PLA_increase_attack_damage.emit(value)
		
		SkillResource.UnlockType.CUSTOM:
			pass

func _is_skill_unlocked(skill_key: String) -> bool:
	return is_skill_unlocked(skill_key)

func _get_skill_level(skill_key: String) -> int:
	return get_skill_level(skill_key)
