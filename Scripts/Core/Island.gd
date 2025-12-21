extends Stage

func _ready() -> void:
	super._ready()
	if SaveSystem.save_data:
		await get_tree().process_frame
		await get_tree().process_frame
		
		SaveSystem.apply_game_data_when_ready()
		
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		
		SaveSystem.apply_player_position()
		EventSystem.PLA_unfreeze_player.emit()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func scatter_node_loaded() -> void:
	super.scatter_node_loaded()
