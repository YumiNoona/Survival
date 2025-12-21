extends Stage

@onready var btn_start: Button = %BTN_Start
@onready var btn_load: Button = %BTN_Load

var is_loading_game: bool = false

func _ready() -> void:
	super._ready()
	_update_menu_buttons()

func _update_menu_buttons() -> void:
	var has_save = SaveSystem.save_file_exists()
	
	if btn_start:
		if has_save:
			btn_start.text = "New Game"
		else:
			btn_start.text = "Play"
	
	if btn_load:
		btn_load.visible = has_save

func _on_btn_start_pressed() -> void:
	is_loading_game = false
	SaveSystem.save_data = null
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Island)

func _on_btn_load_pressed() -> void:
	is_loading_game = true
	SaveSystem.load_game()
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Island)

func _on_btn_settings_pressed() -> void:
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SettingsMenu, false)

func _on_btn_credits_pressed() -> void:
	EventSystem.STA_change_stage.emit(StageConfig.Keys.Credits)

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
