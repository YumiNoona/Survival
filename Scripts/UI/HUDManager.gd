extends Control

const FADE_TIME = 0.25
const TRANSPARENT_COLOR = Color(1, 1, 1, 0)
const VISIBLE_COLOR = Color(1, 1, 1, 1)

@onready var mission_ui: Control = $MarginContainer/MissionUI
@onready var day_timer_ui: Control = $MarginContainer/DayTimerUI
@onready var player_stats_container: Control = $MarginContainer/PlayerStatsContainer

func _ready() -> void:
	EventSystem.BUL_create_bulletin.connect(_on_bulletin_created)
	EventSystem.BUL_destroy_bulletin.connect(_on_bulletin_destroyed)

func _on_bulletin_created(bulletin_key: BulletinConfig.Keys, _extra_arg = null) -> void:
	if bulletin_key == BulletinConfig.Keys.CraftingMenu:
		_fade_hud_elements_out()

func _on_bulletin_destroyed(bulletin_key: BulletinConfig.Keys) -> void:
	if bulletin_key == BulletinConfig.Keys.CraftingMenu:
		_fade_hud_elements_in()

func _fade_hud_elements_out() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	if mission_ui:
		tween.tween_property(mission_ui, "modulate", TRANSPARENT_COLOR, FADE_TIME)
	
	if day_timer_ui:
		tween.tween_property(day_timer_ui, "modulate", TRANSPARENT_COLOR, FADE_TIME)
	
	if player_stats_container:
		tween.tween_property(player_stats_container, "modulate", TRANSPARENT_COLOR, FADE_TIME)
	
	tween.tween_callback(_hide_elements).set_delay(FADE_TIME)

func _fade_hud_elements_in() -> void:
	if mission_ui:
		mission_ui.visible = true
		mission_ui.modulate = TRANSPARENT_COLOR
	if day_timer_ui:
		day_timer_ui.visible = true
		day_timer_ui.modulate = TRANSPARENT_COLOR
	if player_stats_container:
		player_stats_container.visible = true
		player_stats_container.modulate = TRANSPARENT_COLOR
	var tween = create_tween()
	tween.set_parallel(true)

	if mission_ui:
		tween.tween_property(mission_ui, "modulate", VISIBLE_COLOR, FADE_TIME)
	if day_timer_ui:
		tween.tween_property(day_timer_ui, "modulate", VISIBLE_COLOR, FADE_TIME)
	if player_stats_container:
		tween.tween_property(player_stats_container, "modulate", VISIBLE_COLOR, FADE_TIME)

func _hide_elements() -> void:
	if mission_ui:
		mission_ui.visible = false
	if day_timer_ui:
		day_timer_ui.visible = false
	if player_stats_container:
		player_stats_container.visible = false
