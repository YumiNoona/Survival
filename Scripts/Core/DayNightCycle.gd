extends AnimationPlayer


func _enter_tree() -> void:
	EventSystem.GAM_fast_forward_day_night_anim.connect(fast_forward_anim)
	EventSystem.TIM_time_updated.connect(_on_time_updated)


func _ready() -> void:
	await get_tree().physics_frame
	if has_node("/root/DayTimerManager"):
		var hour = DayTimerManager.get_hour()
		set_time(hour)
	else:
		set_time(12)


func set_time(time:float) -> void:
	seek(time)


func fast_forward_anim(time:float) -> void:
	seek(fmod(current_animation_position + time, current_animation_length))

func _on_time_updated(hour: float, _day: int) -> void:
	set_time(hour)
