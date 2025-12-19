extends Node

const SLEEP_HOURS: float = 8.0 

func _enter_tree() -> void:
	EventSystem.PLA_player_sleep.connect(start_sleep_sequence)


func start_sleep_sequence() -> void:
	EventSystem.PLA_freeze_player.emit()
	EventSystem.GAM_game_fade_in.emit(2, game_faded_in)


func game_faded_in() -> void:
	if has_node("/root/DayTimerManager"):
		DayTimerManager.skip_time(SLEEP_HOURS)
	else:
		EventSystem.GAM_fast_forward_day_night_anim.emit(SLEEP_HOURS)
	
	await get_tree().create_timer(1.5).timeout
	
	EventSystem.PLA_unfreeze_player.emit()
	EventSystem.GAM_game_fade_out.emit(1)
