extends Node

var MAX_ENERGY = 100.0
var MAX_HEALTH = 100.0

var current_energy = MAX_ENERGY
var current_health = MAX_HEALTH

func _enter_tree() -> void:
	EventSystem.PLA_change_energy.connect(change_energy)
	EventSystem.PLA_change_health.connect(change_health)
	EventSystem.PLA_increase_max_health.connect(_on_increase_max_health)
	EventSystem.PLA_increase_max_energy.connect(_on_increase_max_energy)

func change_energy(energy_change: float) -> void:
	current_energy += energy_change

	if current_energy < 0:
		change_health(current_energy)

	current_energy = clampf(current_energy, 0, MAX_ENERGY)
	EventSystem.PLA_energy_updated.emit(MAX_ENERGY, current_energy)


func change_health(health_change: float) -> void:
	current_health = clampf(current_health + health_change, 0, MAX_HEALTH)
	EventSystem.PLA_health_updated.emit(MAX_HEALTH, current_health)
	
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
