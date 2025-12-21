extends Control

@onready var time_label: Label = %TimeLabel
@onready var day_label: Label = %DayLabel

var signals_connected := false

func _enter_tree() -> void:
	if signals_connected:
		return
	
	EventSystem.TIM_time_updated.connect(_on_time_updated)
	EventSystem.TIM_day_changed.connect(_on_day_changed)
	signals_connected = true

func _ready() -> void:
	if has_node("/root/DayTimerManager"):
		var hour = DayTimerManager.get_hour()
		var day = DayTimerManager.get_day()
		_on_time_updated(hour, day)

func _on_time_updated(hour: float, day: int) -> void:
	if not is_node_ready():
		return
	
	if not time_label or not day_label:
		return

	var hours = int(hour)
	var minutes = int((hour - hours) * 60.0)
	time_label.text = "%02d:%02d" % [hours, minutes]
	day_label.text = "Day %d" % day

func _on_day_changed(day: int) -> void:
	if not is_node_ready():
		return
	
	if not day_label:
		return
	
	day_label.text = "Day %d" % day
