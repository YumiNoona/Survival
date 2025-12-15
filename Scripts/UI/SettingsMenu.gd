extends FadingBulletin


@onready var volume_label: Label = %VolumeLabel
@onready var sfx_label: Label = %SFXLabel
@onready var resolution_label: Label = %ResolutionLabel

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var resloution_slider: HSlider = %ResloutionSlider
@onready var ssaa_check_button: CheckButton = %SSAACheckButton
@onready var full_screen_check_button: CheckButton = %FullScreenCheckButton



var open_pause_menu_after_closing := false


func initialize(_open_pause_menu_after_closing : bool) -> void:
	open_pause_menu_after_closing = _open_pause_menu_after_closing


func _ready() -> void:
	EventSystem.SET_ask_settings_resource.emit(set_settings_visuals)
	
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	resloution_slider.value_changed.connect(_on_resloution_slider_value_changed)
	ssaa_check_button.toggled.connect(_on_ssaa_check_button_toggled)
	full_screen_check_button.toggled.connect(_on_full_screen_check_button_toggled)
	
	super()


func fade_in() -> void:
	create_tween().tween_property(background, "color", BG_NORMAL_COLOR, BG_FADE_TIME / 2.0)


func set_settings_visuals(settings_resource : SettingsResource) -> void:
	update_volume_label(settings_resource.music_volume)
	music_slider.value = settings_resource.music_volume
	
	update_sfx_label(settings_resource.sfx_volume)
	sfx_slider.value = settings_resource.sfx_volume
	
	update_res_scale_label(settings_resource.res_scale)
	resloution_slider.value = settings_resource.res_scale
	
	ssaa_check_button.button_pressed = settings_resource.ssaa_enabled
	
	full_screen_check_button.button_pressed = settings_resource.fullscreen_enabled


func _on_music_slider_value_changed(value: float) -> void:
	EventSystem.SET_music_volume_changed.emit(value)
	update_volume_label(value)


func update_volume_label(value: float) -> void:
	volume_label.text = str(snappedi(value * 100, 1)) + " %"


func _on_sfx_slider_value_changed(value: float) -> void:
	EventSystem.SET_sfx_volume_changed.emit(value)
	update_sfx_label(value)

func update_sfx_label(value: float) -> void:
	sfx_label.text = str(snappedi(value * 100, 1)) + " %"


func _on_resloution_slider_value_changed(value: float) -> void:
	EventSystem.SET_res_scale_changed.emit(value)
	update_res_scale_label(value)

func update_res_scale_label(value: float) -> void:
	resolution_label.text = str(snappedi(value * 100, 1)) + " %"


func _on_ssaa_check_button_toggled(toggled_on: bool) -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
	EventSystem.SET_ssaa_changed.emit(toggled_on)


func _on_full_screen_check_button_toggled(toggled_on: bool) -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
	EventSystem.SET_fullscreen_changed.emit(toggled_on)


func _on_btn_close_pressed() -> void:
	fade_out()
	
	EventSystem.SET_save_settings.emit()
	
	if open_pause_menu_after_closing:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)


func destroy_self() -> void:
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.SettingsMenu)
