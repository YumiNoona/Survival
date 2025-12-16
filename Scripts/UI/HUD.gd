extends Node

@onready var hud: Control = $HUD

func _enter_tree() -> void:
	EventSystem.HUD_hide_hud.connect(hide_hud)
	EventSystem.HUD_show_hud.connect(show_hud)


func _ready() -> void:
	hide_hud()


func hide_hud() -> void:
	if hud and hud.get_parent() == self:
		remove_child(hud)


func show_hud() -> void:
	if hud and hud.get_parent() != self:
		add_child(hud)
