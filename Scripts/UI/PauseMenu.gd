extends FadingBulletin

const BUTTON_FADE_TIME = 0.15

@onready var btn_resume: Button = $VBoxContainer/BTN_Resume
@onready var btn_settings: Button = $VBoxContainer/BTN_Settings
@onready var btn_quit: Button = $VBoxContainer/BTN_Quit


func _ready() -> void:
	btn_resume.modulate = TRANSPARENT_COLOR
	btn_settings.modulate = TRANSPARENT_COLOR
	btn_quit.modulate = TRANSPARENT_COLOR
	
	get_tree().paused = true
	
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
	
	super()


func fade_in() -> void:
	super()
	
	var tween := create_tween()
	tween.tween_property(btn_resume, "modulate", Color.WHITE, BUTTON_FADE_TIME)
	tween.tween_property(btn_settings, "modulate", Color.WHITE, BUTTON_FADE_TIME)
	tween.tween_property(btn_quit, "modulate", Color.WHITE, BUTTON_FADE_TIME)


func _on_btn_resume_pressed() -> void:
	EventSystem.HUD_show_hud.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	fade_out()


func _on_btn_settings_pressed() -> void:
	EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SettingsMenu, true)
	fade_out()


func _on_btn_quit_pressed() -> void:
	EventSystem.STA_change_stage.emit(StageConfig.Keys.MainMenu)
