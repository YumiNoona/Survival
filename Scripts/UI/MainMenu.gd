extends Stage

func _on_btn_start_pressed() -> void:
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Island)


func _on_btn_settings_pressed() -> void:
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SettingsMenu, false)


func _on_btn_credits_pressed() -> void:
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Credits)


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
