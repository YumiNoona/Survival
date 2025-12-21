extends Control

@onready var level_label: Label = %LevelLabel

var signals_connected := false

func _enter_tree() -> void:
	if signals_connected:
		return
	EventSystem.LEV_level_updated.connect(_on_level_updated)
	signals_connected = true

func _ready() -> void:
	if has_node("/root/LevelManager"):
		var level = LevelManager.get_level()
		_update_level_display(level)

func _on_level_updated(level: int, _xp_for_next: int, _total_xp: int) -> void:
	if not is_node_ready():
		return
	_update_level_display(level)

func _update_level_display(level: int) -> void:
	if level_label:
		level_label.text = "Level %d" % level
