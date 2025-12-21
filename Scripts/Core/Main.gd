extends Node

var quit_dialog: ConfirmationDialog

func _ready() -> void:
	quit_dialog = ConfirmationDialog.new()
	quit_dialog.dialog_text = "Save before quitting?"
	quit_dialog.get_ok_button().text = "Yes"
	quit_dialog.get_cancel_button().text = "No"
	quit_dialog.confirmed.connect(_on_quit_dialog_confirmed)
	quit_dialog.canceled.connect(_on_quit_dialog_canceled)
	quit_dialog.close_requested.connect(_on_quit_dialog_closed)
	add_child(quit_dialog)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var should_ask = _should_ask_to_save()
		if should_ask:
			quit_dialog.popup_centered()
		else:
			get_tree().quit()

func _should_ask_to_save() -> bool:
	var current_stage = get_node_or_null("StageController")
	if current_stage and current_stage.get_child_count() > 0:
		var stage = current_stage.get_child(0)
		if stage.name == "MainMenu":
			return false
	
	var player = get_tree().get_first_node_in_group("Player")
	var has_missions = false
	if has_node("/root/MissionManager"):
		var mission_manager = get_node("/root/MissionManager")
		if mission_manager and (mission_manager.active_missions.size() > 0 or mission_manager.completed_missions.size() > 0):
			has_missions = true
	
	return player != null or has_missions

func _on_quit_dialog_confirmed() -> void:
	quit_dialog.hide()
	_perform_save_and_quit()

func _on_quit_dialog_canceled() -> void:
	quit_dialog.hide()
	get_tree().quit()

func _on_quit_dialog_closed() -> void:
	_on_quit_dialog_canceled()

func _perform_save_and_quit() -> void:
	if get_tree().paused:
		get_tree().paused = false
	
	EventSystem.PLA_unfreeze_player.emit()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "", "")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	SaveSystem.save_game()
	
	await get_tree().process_frame
	get_tree().quit()
