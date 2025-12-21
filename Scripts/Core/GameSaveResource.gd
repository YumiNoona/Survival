extends Resource
class_name GameSaveResource

# Player stats
@export var max_health: float = 100.0
@export var max_energy: float = 100.0
@export var max_hunger: float = 100.0
@export var current_health: float = 100.0
@export var current_energy: float = 100.0
@export var current_hunger: float = 100.0

# Player position and rotation
@export var player_position: Vector3 = Vector3.ZERO
@export var player_rotation_y: float = 0.0

# Inventory
@export var inventory: Array = []
@export var hotbar: Array = []
@export var current_inventory_size: int = 28

# XP and Level
@export var total_xp: int = 0
@export var available_xp: int = 0
@export var current_level: int = 1

# Skills
@export var unlocked_skills: Dictionary = {}

# Missions
@export var active_missions: Array[String] = []  # mission_key strings
@export var completed_missions: Array[String] = []  # mission_key strings
@export var mission_progress: Dictionary = {}  # mission_key: progress_data (serialized as Dictionary)

# Day/Time
@export var current_hour: float = 12.0
@export var current_day: int = 1

# Save metadata
@export var save_version: int = 1
@export var save_timestamp: int = 0  # Unix timestamp
