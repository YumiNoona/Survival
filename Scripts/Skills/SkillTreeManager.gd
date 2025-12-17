extends Node

var unlocked_skills: Array[String] = [] 

func _enter_tree() -> void:
	EventSystem.SKL_try_unlock_skill.connect(try_unlock_skill)
	EventSystem.SKL_is_skill_unlocked.connect(_is_skill_unlocked)

func is_skill_unlocked(skill_key: String) -> bool:
	return skill_key in unlocked_skills

func can_unlock_skill(skill_key: String) -> bool:
	var skill = SkillConfig.get_skill_resource(skill_key)
	if not skill:
		return false
	

	if is_skill_unlocked(skill_key):
		return false

	for prereq_key in skill.prerequisites:
		if not is_skill_unlocked(prereq_key):
			return false

	var xp_manager = XPManager
	if xp_manager.available_xp < skill.xp_cost:
		return false
	
	return true

func try_unlock_skill(skill_key: String) -> bool:
	if not can_unlock_skill(skill_key):
		return false
	
	var skill = SkillConfig.get_skill_resource(skill_key)
	if not skill:
		return false
	
	# Spend XP
	if not XPManager._spend_xp(skill.xp_cost):
		return false

	unlocked_skills.append(skill_key)
	apply_skill_effect(skill)
	EventSystem.SKL_skill_unlocked.emit(skill_key)
	return true

func apply_skill_effect(skill: SkillResource) -> void:
	match skill.unlock_type:
		SkillResource.UnlockType.INVENTORY_SLOTS:
			EventSystem.INV_add_inventory_slots.emit(skill.unlock_value)
		
		SkillResource.UnlockType.DOUBLE_JUMP:
			EventSystem.PLA_enable_double_jump.emit()
		
		SkillResource.UnlockType.WEAPON_TIER:
			EventSystem.CRAFT_unlock_weapon_tier.emit(skill.unlock_value)
		
		SkillResource.UnlockType.CRAFTING_RECIPE:
			EventSystem.CRAFT_unlock_recipe.emit(skill.unlock_data)
		
		SkillResource.UnlockType.MOVEMENT_SPEED:
			EventSystem.PLA_increase_movement_speed.emit(skill.unlock_value)
		
		SkillResource.UnlockType.HEALTH_BONUS:
			EventSystem.PLA_increase_max_health.emit(skill.unlock_value)
		
		SkillResource.UnlockType.ENERGY_BONUS:
			EventSystem.PLA_increase_max_energy.emit(skill.unlock_value)
		
		SkillResource.UnlockType.ATTACK_DAMAGE:
			EventSystem.PLA_increase_attack_damage.emit(skill.unlock_value)
		
		SkillResource.UnlockType.CUSTOM:
			pass

func _is_skill_unlocked(skill_key: String) -> bool:
	return is_skill_unlocked(skill_key)
