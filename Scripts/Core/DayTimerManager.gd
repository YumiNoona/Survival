extends Node

var current_hour: float = 12.0  
var current_day: int = 1
var time_speed: float = 1.0  

const HOURS_PER_DAY: float = 24.0
const MINUTES_PER_HOUR: float = 60.0
const SECONDS_PER_MINUTE: float = 60.0


var real_seconds_per_game_hour: float = 60.0

var last_emitted_minute: int = -1

func _enter_tree() -> void:
	EventSystem.TIM_skip_time.connect(skip_time)
	EventSystem.TIM_set_time_speed.connect(set_time_speed)

func _ready() -> void:
	call_deferred("_emit_initial_time")
	last_emitted_minute = int(current_hour * MINUTES_PER_HOUR)

func _emit_initial_time() -> void:
	EventSystem.TIM_time_updated.emit(current_hour, current_day)

func _process(delta: float) -> void:
	var time_delta = delta * time_speed / real_seconds_per_game_hour
	current_hour += time_delta
	

	if current_hour >= HOURS_PER_DAY:
		current_hour = fmod(current_hour, HOURS_PER_DAY)
		current_day += 1
		EventSystem.TIM_day_changed.emit(current_day)
	

	var current_minute = int(current_hour * MINUTES_PER_HOUR)
	if current_minute != last_emitted_minute:
		EventSystem.TIM_time_updated.emit(current_hour, current_day)
		last_emitted_minute = current_minute

func skip_time(hours: float) -> void:
	"""Skip forward by specified hours"""
	current_hour += hours
	

	while current_hour >= HOURS_PER_DAY:
		current_hour -= HOURS_PER_DAY
		current_day += 1
		EventSystem.TIM_day_changed.emit(current_day)
	

	EventSystem.TIM_time_updated.emit(current_hour, current_day)
	EventSystem.GAM_fast_forward_day_night_anim.emit(hours)

func set_time_speed(speed: float) -> void:
	"""Set the time speed multiplier"""
	time_speed = max(0.0, speed)  

func set_time(hour: float, day: int = 1) -> void:
	"""Set the current time directly"""
	current_hour = fmod(hour, HOURS_PER_DAY)
	current_day = max(1, day)
	EventSystem.TIM_time_updated.emit(current_hour, current_day)

func get_time_string() -> String:
	"""Get formatted time string (e.g., "Day 1 - 14:30")"""
	var hours = int(current_hour)
	var minutes = int((current_hour - hours) * MINUTES_PER_HOUR)
	return "Day %d - %02d:%02d" % [current_day, hours, minutes]

func get_hour() -> float:
	"""Get current hour (0-24)"""
	return current_hour

func get_day() -> int:
	"""Get current day"""
	return current_day

func is_daytime() -> bool:
	"""Check if it's daytime (6:00 to 18:00)"""
	return current_hour >= 6.0 and current_hour < 18.0

func is_nighttime() -> bool:
	"""Check if it's nighttime"""
	return not is_daytime()
