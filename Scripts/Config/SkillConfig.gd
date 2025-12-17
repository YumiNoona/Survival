class_name SkillConfig


const SKILL_RESOURCE_PATHS := {
	# Combat Skills
	"combat_basic_training": "res://Resources/Skills/Combat/Skill_BasicTraining.tres",
	"combat_critical_strikes": "res://Resources/Skills/Combat/Skill_CriticalStrikes.tres",
	"combat_combat_reflexes": "res://Resources/Skills/Combat/Skill_CombatReflexes.tres",
	"combat_battle_hardened": "res://Resources/Skills/Combat/Skill_BattleHardened.tres",
	"combat_combat_regeneration": "res://Resources/Skills/Combat/Skill_CombatRegeneration.tres",
	"combat_executioner": "res://Resources/Skills/Combat/Skill_Executioner.tres",
	
	# Exploration Skills
	"exploration_double_jump": "res://Resources/Skills/Exploration/Skill_DoubleJump.tres",
	"exploration_swift_feet": "res://Resources/Skills/Exploration/Skill_SwiftFeet.tres",
	"exploration_enhanced_sprint": "res://Resources/Skills/Exploration/Skill_EnhancedSprint.tres",
	"exploration_mountain_goat": "res://Resources/Skills/Exploration/Skill_MountainGoat.tres",
	
	# Survival Skills
	"survival_extra_pockets": "res://Resources/Skills/Survival/Skill_ExtraPockets.tres",
	"survival_pack_mule": "res://Resources/Skills/Survival/Skill_PackMule.tres",
	"survival_vitality_boost": "res://Resources/Skills/Survival/Skill_VitalityBoost.tres",
	"survival_endurance_training": "res://Resources/Skills/Survival/Skill_EnduranceTraining.tres",
	"survival_natural_regeneration": "res://Resources/Skills/Survival/Skill_NaturalRegeneration.tres",
	
	# Crafting Skills
	"crafting_efficient_crafting": "res://Resources/Skills/Crafting/Skill_EfficientCrafting.tres",
	"crafting_quick_hands": "res://Resources/Skills/Crafting/Skill_QuickHands.tres",
}

static func get_skill_resource(skill_key: String) -> SkillResource:
	if SKILL_RESOURCE_PATHS.has(skill_key):
		return load(SKILL_RESOURCE_PATHS[skill_key])
	return null

static func get_all_skills() -> Array[SkillResource]:
	var skills: Array[SkillResource] = []
	for skill_key in SKILL_RESOURCE_PATHS.keys():
		var skill = get_skill_resource(skill_key)
		if skill:
			skills.append(skill)
	return skills

static func get_skills_by_category(category: SkillResource.SkillCategory) -> Array[SkillResource]:
	var skills: Array[SkillResource] = []
	for skill_key in SKILL_RESOURCE_PATHS.keys():
		var skill = get_skill_resource(skill_key)
		if skill and skill.category == category:
			skills.append(skill)
	return skills
