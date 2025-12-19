extends Line2D
class_name AnimatedSkillLine

var animation_speed := 1.5
var animation_progress := 0.0
var is_unlocked := false
var base_color := Color.WHITE

func setup_line(from_pos: Vector2, to_pos: Vector2, unlocked: bool) -> void:
	is_unlocked = unlocked
	width = 8.0  # Thicker line
	antialiased = true  # Smooth edges
	
	# Set line points
	points = PackedVector2Array([from_pos, to_pos])
	
	# Set colors based on unlock status
	if unlocked:
		base_color = Color(0.2, 0.8, 1.0, 1.0)  # Bright cyan for unlocked
		default_color = base_color
	else:
		base_color = Color(0.4, 0.4, 0.4, 0.6)  # Gray for locked (more visible)
		default_color = base_color
	
	# Start animation
	animation_progress = 0.0
	set_process(true)

func _process(delta: float) -> void:
	animation_progress += delta * animation_speed
	if animation_progress > 1.0:
		animation_progress = fmod(animation_progress, 1.0)
	
	var pulse: float
	var animated_color: Color
	
	if not is_unlocked:
		# Subtle pulse for locked lines
		pulse = sin(animation_progress * TAU) * 0.1 + 0.9
		animated_color = Color(
			base_color.r * pulse,
			base_color.g * pulse,
			base_color.b * pulse,
			base_color.a
		)
		default_color = animated_color
		return
	
	# Enhanced animation for unlocked lines - flowing energy effect
	# Create a flowing wave along the line
	var wave = sin(animation_progress * TAU * 2.0) * 0.3 + 0.7
	pulse = sin(animation_progress * TAU) * 0.25 + 0.75
	
	# Combine wave and pulse for dynamic effect
	var brightness = wave * pulse
	animated_color = Color(
		base_color.r * brightness,
		base_color.g * brightness,
		base_color.b * brightness,
		base_color.a
	)
	default_color = animated_color
	
	# Animate width slightly for more dynamic feel
	width = 8.0 + sin(animation_progress * TAU * 1.5) * 1.5
