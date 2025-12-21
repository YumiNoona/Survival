extends Resource
class_name MissionRequirement

# Helper resource for mission item requirements
# Makes it easier to define in .tres files

@export var item_id: int = 0  # Item ID (integer ID used in inventory: Stick=0, Stone=1, etc.)
@export var amount: int = 1
