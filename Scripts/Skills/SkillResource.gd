extends Resource
class_name SkillResource

enum SkillCategory {
	COMBAT,
	SURVIVAL,
	CRAFTING,
	EXPLORATION
}

enum UnlockType {
	INVENTORY_SLOTS,      
	DOUBLE_JUMP,          
	WEAPON_TIER,         
	CRAFTING_RECIPE,      
	MOVEMENT_SPEED,       
	HEALTH_BONUS,         
	ENERGY_BONUS,         
	ATTACK_DAMAGE,   
	CUSTOM                
}

@export var skill_key: String = "" 
@export var display_name: String = "Skill Name"
@export_multiline var description: String = "Skill description"
@export var icon: Texture2D
@export var category: SkillCategory = SkillCategory.COMBAT
@export var xp_cost: int = 10
@export var position: Vector2 = Vector2(0, 0) 
@export var prerequisites: Array[String] = [] 
@export var unlock_type: UnlockType = UnlockType.CUSTOM
@export var unlock_value: int = 0  
@export var unlock_data: String = "" 
