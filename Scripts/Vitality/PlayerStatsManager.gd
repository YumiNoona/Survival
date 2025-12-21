extends Node

var MAX_ENERGY = 100.0
var MAX_HEALTH = 100.0

var current_energy = MAX_ENERGY
var current_health = MAX_HEALTH

# Health regeneration system
const COMBAT_TIMEOUT: float = 5.0  # Seconds after taking damage before considered "out of combat"
const NATURAL_REGEN_RATE: float = 1.0 / 10.0  # 1 HP per 10 seconds
const COMBAT_REGEN_RATE: float = 1.0 / 5.0  # 1 HP per 5 seconds

var time_since_last_damage: float = 999.0  # Start as "not in combat"
var regeneration_timer: float = 0.0

func _enter_tree() -> void:
	EventSystem.PLA_change_energy.connect(change_energy)
	EventSystem.PLA_change_health.connect(change_health)
	EventSystem.PLA_increase_max_health.connect(_on_increase_max_health)
	EventSystem.PLA_increase_max_energy.connect(_on_increase_max_energy)

func _process(delta: float) -> void:
	# Update combat timer
	time_since_last_damage += delta
	
	# Only regenerate if health is below max
	if current_health < MAX_HEALTH:
		_process_regeneration(delta)

func _process_regeneration(delta: float) -> void:
	# Check if regeneration skills are unlocked
	var has_natural_regen = false
	var has_combat_regen = false
	
	if has_node("/root/SkillTreeManager"):
		has_natural_regen = SkillTreeManager.is_skill_unlocked("survival_natural_regeneration")
		has_combat_regen = SkillTreeManager.is_skill_unlocked("combat_combat_regeneration")
	
	# Determine if in combat (took damage recently)
	var is_in_combat = time_since_last_damage < COMBAT_TIMEOUT
	
	# Apply regeneration based on state and skills
	var regen_rate = 0.0
	
	if is_in_combat:
		# In combat - use combat regeneration if unlocked
		if has_combat_regen:
			regen_rate = COMBAT_REGEN_RATE
	elif not is_in_combat:
		# Out of combat - use natural regeneration if unlocked
		if has_natural_regen:
			regen_rate = NATURAL_REGEN_RATE
	
	# Apply regeneration
	if regen_rate > 0.0:
		regeneration_timer += delta * regen_rate
		
		# Heal in 1 HP increments
		if regeneration_timer >= 1.0:
			var heal_amount = floor(regeneration_timer)
			regeneration_timer -= heal_amount
			
			# Heal without triggering combat state
			current_health = min(current_health + heal_amount, MAX_HEALTH)
			EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)

func change_energy(energy_change: float) -> void:
	var new_energy = current_energy + energy_change
	
	# If energy would go negative, the excess drains health
	if new_energy < 0:
		var excess_damage = -new_energy  # Amount that exceeds 0 (always positive)
		change_health(-excess_damage)  # Apply as negative health change (damage)
		new_energy = 0
	
	current_energy = clampf(new_energy, 0, MAX_ENERGY)
	EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)


func change_health(health_change: float) -> void:
	current_health = clampf(current_health + health_change, 0, MAX_HEALTH)
	EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)
	
	# If taking damage (negative change), reset combat timer
	if health_change < 0:
		time_since_last_damage = 0.0
	
	if current_health <= 0:
		EventSystem.PLA_freeze_player.emit()
		EventSystem.STA_change_stage.emit(StageConfig.Keys.MainMenu)

func _on_increase_max_health(amount: int) -> void:
	MAX_HEALTH += amount
	current_health += amount  # Also increase current health
	EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)

func _on_increase_max_energy(amount: int) -> void:
	MAX_ENERGY += amount
	current_energy += amount  # Also increase current energy
	EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)
