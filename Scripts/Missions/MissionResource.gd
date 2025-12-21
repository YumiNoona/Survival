extends Resource
class_name MissionResource

enum MissionType {
	COLLECT_ITEMS,      # Collect specific items (e.g., 3 sticks, 3 stones)
	CRAFT_ITEM,         # Craft a specific item (e.g., craft a weapon)
	KILL_ENEMY,         # Kill enemies/animals
	BUILD_STRUCTURE,    # Build/place structures
	CUSTOM              # Custom mission type
}

enum MissionCategory {
	MAIN_MISSION,       # Main story missions
	SUB_MISSION         # Side/optional missions
}

@export var mission_key: String = ""  # Unique identifier (e.g., "mission_01_collect_resources")
@export var mission_name: String = "Mission Name"
@export_multiline var mission_description: String = "Mission description"
@export var mission_type: MissionType = MissionType.COLLECT_ITEMS
@export var xp_reward: int = 10  # XP awarded on completion

# For COLLECT_ITEMS missions
@export var required_items: Array[MissionRequirement] = []  # Array of MissionRequirement resources

# For CRAFT_ITEM missions
@export var required_craft_item: ItemConfig.Keys = ItemConfig.Keys.Axe  # Item that must be crafted

# For KILL_ENEMY missions
@export var required_kills: int = 1  # Number of enemies to kill

# For BUILD_STRUCTURE missions
@export var required_structure: ItemConfig.Keys = ItemConfig.Keys.Campfire  # Structure to build

# Mission level/tier (for progression)
@export var mission_level: int = 1

# Mission category (Main or Sub mission)
@export var mission_category: MissionCategory = MissionCategory.MAIN_MISSION

# Prerequisites (other missions that must be completed first)
@export var prerequisite_missions: Array[String] = []  # Array of mission_key strings
