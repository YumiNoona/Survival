extends Control
class_name LevelUpNotification

@onready var level_label: Label = %LevelLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var particles: GPUParticles2D = %Particles

var level: int = 1

func setup_notification(new_level: int) -> void:
	level = new_level
	if level_label:
		level_label.text = "LEVEL %d!" % level

func _ready() -> void:
	if animation_player:
		animation_player.play("level_up")
	
	# Auto-dismiss after 4 seconds
	var timer = get_tree().create_timer(4.0)
	timer.timeout.connect(_on_auto_dismiss)

func _on_auto_dismiss() -> void:
	if animation_player:
		animation_player.play("fade_out")
		await animation_player.animation_finished
	queue_free()
