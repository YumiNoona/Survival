extends Node

var MAX_ENERGY = 100.0
var MAX_HEALTH = 100.0
var MAX_HUNGER = 100.0

var current_energy = MAX_ENERGY
var current_health = MAX_HEALTH
var current_hunger = MAX_HUNGER

# Health regeneration system
const COMBAT_TIMEOUT: float = 5.0  
const NATURAL_REGEN_RATE: float = 1.0 / 10.0  
const COMBAT_REGEN_RATE: float = 1.0 / 5.0  

# Hunger system
const HUNGER_DECAY_RATE: float = 1.0 / 60.0  
const HUNGER_TO_HEALTH_DAMAGE: float = 0.5  

var time_since_last_damage: float = 999.0  
var regeneration_timer: float = 0.0
var hunger_decay_timer: float = 0.0

func _enter_tree() -> void:
	EventSystem.PLA_change_energy.connect(change_energy)
	EventSystem.PLA_change_health.connect(change_health)
	EventSystem.PLA_change_hunger.connect(change_hunger)
	EventSystem.PLA_increase_max_health.connect(_on_increase_max_health)
	EventSystem.PLA_increase_max_energy.connect(_on_increase_max_energy)

func _process(delta: float) -> void:
	time_since_last_damage += delta
	_process_hunger_decay(delta)


	if current_hunger <= 0 and current_health > 0:
		change_health(-HUNGER_TO_HEALTH_DAMAGE * delta)


	if current_health < MAX_HEALTH:
		_process_regeneration(delta)

func _process_regeneration(delta: float) -> void:
	var has_natural_regen = false
	var has_combat_regen = false
	
	if has_node("/root/SkillTreeManager"):
		has_natural_regen = SkillTreeManager.is_skill_unlocked("survival_natural_regeneration")
		has_combat_regen = SkillTreeManager.is_skill_unlocked("combat_combat_regeneration")
	var is_in_combat = time_since_last_damage < COMBAT_TIMEOUT
	var regen_rate = 0.0
	
	if is_in_combat:
		if has_combat_regen:
			regen_rate = COMBAT_REGEN_RATE
	elif not is_in_combat:
		if has_natural_regen:
			regen_rate = NATURAL_REGEN_RATE


	if regen_rate > 0.0:
		regeneration_timer += delta * regen_rate


		if regeneration_timer >= 1.0:
			var heal_amount = floor(regeneration_timer)
			regeneration_timer -= heal_amount
			current_health = min(current_health + heal_amount, MAX_HEALTH)
			EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)

func change_energy(energy_change: float) -> void:
	var new_energy = current_energy + energy_change


	if new_energy < 0:
		var excess_damage = -new_energy 
		change_health(-excess_damage)  
		new_energy = 0
	
	current_energy = clampf(new_energy, 0, MAX_ENERGY)
	EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)


func change_health(health_change: float) -> void:
	current_health = clampf(current_health + health_change, 0, MAX_HEALTH)
	EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)


	if health_change < 0:
		time_since_last_damage = 0.0
	
	if current_health <= 0:
		EventSystem.PLA_freeze_player.emit()
		EventSystem.STA_change_stage.emit(StageConfig.Keys.MainMenu)

func _on_increase_max_health(amount: int) -> void:
	MAX_HEALTH += amount
	current_health += amount  
	EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)

func _on_increase_max_energy(amount: int) -> void:
	MAX_ENERGY += amount
	current_energy += amount  
	EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)

func _process_hunger_decay(delta: float) -> void:
	hunger_decay_timer += delta * HUNGER_DECAY_RATE
	
	if hunger_decay_timer >= 1.0:
		var decay_amount = floor(hunger_decay_timer)
		hunger_decay_timer -= decay_amount
		change_hunger(-decay_amount)

func change_hunger(hunger_change: float) -> void:
	current_hunger = clampf(current_hunger + hunger_change, 0, MAX_HUNGER)
	EventSystem.PLA_hunger_updated.emit(MAX_HUNGER, current_hunger)
