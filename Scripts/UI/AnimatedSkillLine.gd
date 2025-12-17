extends Line2D
class_name AnimatedSkillLine

var animation_speed := 1.5
var animation_progress := 0.0
var is_unlocked := false
var base_color := Color.WHITE

func setup_line(from_pos: Vector2, to_pos: Vector2, unlocked: bool) -> void:
	is_unlocked = unlocked
	width = 5.0
	
	# Set line points
	points = PackedVector2Array([from_pos, to_pos])
	
	# Set colors based on unlock status
	if unlocked:
		base_color = Color(0.2, 0.8, 1.0, 1.0)  # Bright cyan for unlocked
		default_color = base_color
	else:
		base_color = Color(0.4, 0.4, 0.4, 0.5)  # Gray for locked
		default_color = base_color
	
	# Start animation
	animation_progress = 0.0
	set_process(true)

func _process(delta: float) -> void:
	if not is_unlocked:
		# Static gray line for locked
		default_color = base_color
		return
	
	# Animate the line with a flowing pulse effect
	animation_progress += delta * animation_speed
	if animation_progress > 1.0:
		animation_progress = fmod(animation_progress, 1.0)
	
	# Create pulsing brightness effect
	var pulse = sin(animation_progress * TAU) * 0.2 + 0.8
	var animated_color = Color(
		base_color.r * pulse,
		base_color.g * pulse,
		base_color.b * pulse,
		base_color.a
	)
	default_color = animated_color
