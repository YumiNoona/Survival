class_name MissionConfig

# Mission configuration - defines all available missions
# Similar to SkillConfig, but for missions

const MISSION_RESOURCE_PATHS := {
	"mission_01_collect_resources": "res://Resources/Missions/Mission_01_CollectResources.tres",
	"mission_02_craft_weapon": "res://Resources/Missions/Mission_02_CraftWeapon.tres",
	"mission_03_explore_forest": "res://Resources/Missions/Mission_03_ExploreForest.tres",
	"mission_04_craft_torch": "res://Resources/Missions/Mission_04_CraftTorch.tres",
	"mission_05_craft_campfire": "res://Resources/Missions/Mission_05_CraftCampfire.tres",
	"mission_06_gather_food": "res://Resources/Missions/Mission_06_GatherFood.tres",
	"mission_07_mine_resources": "res://Resources/Missions/Mission_07_MineResources.tres",
	"mission_08_craft_pickaxe": "res://Resources/Missions/Mission_08_CraftPickaxe.tres",
	"mission_09_craft_multitool": "res://Resources/Missions/Mission_09_CraftMultitool.tres",
	"mission_10_craft_rope": "res://Resources/Missions/Mission_10_CraftRope.tres",
	"mission_11_craft_tent": "res://Resources/Missions/Mission_11_CraftTent.tres",
	"mission_12_craft_tinderbox": "res://Resources/Missions/Mission_12_CraftTinderbox.tres",
	"mission_13_extensive_exploration": "res://Resources/Missions/Mission_13_ExtensiveExploration.tres",
	"mission_14_resource_stockpile": "res://Resources/Missions/Mission_14_ResourceStockpile.tres",
	"mission_15_final_preparation": "res://Resources/Missions/Mission_15_FinalPreparation.tres",
}

static func get_mission_resource(mission_key: String) -> MissionResource:
	if MISSION_RESOURCE_PATHS.has(mission_key):
		return load(MISSION_RESOURCE_PATHS[mission_key])
	return null

static func get_all_missions() -> Array[MissionResource]:
	var missions: Array[MissionResource] = []
	for mission_key in MISSION_RESOURCE_PATHS.keys():
		var mission = get_mission_resource(mission_key)
		if mission:
			missions.append(mission)
	return missions

static func get_missions_by_level(level: int) -> Array[MissionResource]:
	var missions: Array[MissionResource] = []
	for mission_key in MISSION_RESOURCE_PATHS.keys():
		var mission = get_mission_resource(mission_key)
		if mission and mission.mission_level == level:
			missions.append(mission)
	return missions
