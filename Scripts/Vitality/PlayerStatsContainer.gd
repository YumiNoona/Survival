extends VBoxContainer


@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var health_bar: TextureProgressBar = $HealthBar


func _enter_tree() -> void:
	EventSystem.PLA_energy_updated.connect(energy_updated)
	EventSystem.PLA_health_updated.connect(health_updated)

func energy_updated(max_energy: float, current_energy: float) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current_energy

func health_updated(max_health: float, current_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
