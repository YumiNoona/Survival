extends Control


@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var health_bar: TextureProgressBar = $HealthBar

var signals_connected := false

func _enter_tree() -> void:
	if signals_connected:
		return
	
	EventSystem.PLA_energy_updated.connect(energy_updated)
	EventSystem.PLA_health_updated.connect(health_updated)
	signals_connected = true

func energy_updated(max_energy: float, current_energy: float) -> void:
	if energy_bar:
		energy_bar.max_value = max_energy
		energy_bar.value = current_energy

func health_updated(max_health: float, current_health: float) -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
