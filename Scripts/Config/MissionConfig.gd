class_name MissionConfig

# Mission configuration - defines all available missions
# Similar to SkillConfig, but for missions

const MISSION_RESOURCE_PATHS := {
	"mission_01_collect_resources": "res://Resources/Missions/Mission_01_CollectResources.tres",
	"mission_02_craft_weapon": "res://Resources/Missions/Mission_02_CraftWeapon.tres",
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
