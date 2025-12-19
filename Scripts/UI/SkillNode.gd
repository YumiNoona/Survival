extends Control
class_name SkillNode

@onready var icon: TextureRect = %Icon
@onready var skill_name_label: Label = %SkillName
@onready var xp_cost_label: Label = %XPCost
@onready var level_label: Label = %LevelLabel
@onready var locked_overlay: ColorRect = %LockedOverlay
@onready var button: Button = %Button
@onready var glow_effect: ColorRect = %GlowEffect
@onready var particles_container: Node2D = %ParticlesContainer

var skill_resource: SkillResource
var skill_key: String = ""
var is_animating: bool = false

signal skill_node_clicked(skill_key: String)
signal skill_node_hovered(skill_key: String)
signal skill_unlock_animation_finished

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)

func setup_skill(_skill_resource: SkillResource) -> void:
	skill_resource = _skill_resource
	skill_key = skill_resource.skill_key
	
	# Update visual elements
	if skill_resource.icon:
		icon.texture = skill_resource.icon
	skill_name_label.text = skill_resource.display_name
	
	# Update position
	position = skill_resource.position
	
	# Update state
	update_skill_state()

func update_skill_state() -> void:
	if not skill_resource:
		return
	
	var current_level = SkillTreeManager.get_skill_level(skill_key)
	var is_unlocked = current_level > 0
	var can_unlock = SkillTreeManager.can_unlock_skill(skill_key)
	
	# Update level label
	if skill_resource.max_level > 1:
		if current_level > 0:
			level_label.text = "Lv.%d/%d" % [current_level, skill_resource.max_level]
			level_label.visible = true
		else:
			level_label.text = "Lv.0/%d" % skill_resource.max_level
			level_label.visible = true
	else:
		level_label.visible = false
	
	# Update XP cost label
	if can_unlock:
		var next_level = current_level + 1
		var xp_cost = SkillTreeManager.get_xp_cost_for_level(skill_resource, next_level)
		xp_cost_label.text = str(xp_cost) + " XP"
		xp_cost_label.visible = true
	elif is_unlocked and current_level >= skill_resource.max_level:
		xp_cost_label.text = "MAX"
		xp_cost_label.visible = true
	else:
		xp_cost_label.text = str(skill_resource.xp_cost) + " XP"
		xp_cost_label.visible = true
	
	if is_unlocked:
		# Unlocked state - check if can upgrade
		if current_level >= skill_resource.max_level:
			# Max level reached
			locked_overlay.visible = false
			modulate = Color(0.8, 0.8, 0.8, 1)  # Slightly dimmed for max level
			button.disabled = true
		elif can_unlock:
			# Can upgrade
			locked_overlay.visible = false
			modulate = Color(1, 1, 1, 1)
			button.disabled = false
		else:
			# Unlocked but can't upgrade yet
			locked_overlay.visible = false
			modulate = Color(1, 1, 1, 1)
			button.disabled = true
	elif can_unlock:
		# Available to unlock
		locked_overlay.visible = false
		modulate = Color(1, 1, 1, 1)
		button.disabled = false
	else:
		# Locked
		locked_overlay.visible = true
		modulate = Color(0.5, 0.5, 0.5, 1)
		button.disabled = true

func _on_button_pressed() -> void:
	if skill_key != "":
		skill_node_clicked.emit(skill_key)
		EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _on_mouse_entered() -> void:
	if skill_key != "":
		skill_node_hovered.emit(skill_key)

func _on_mouse_exited() -> void:
	pass

func play_unlock_animation() -> void:
	if is_animating:
		return
	
	is_animating = true
	
	# Remove locked overlay immediately
	locked_overlay.visible = false
	
	# Create unlock animation sequence
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale animation - pop effect
	var original_scale = scale
	tween.tween_property(self, "scale", original_scale * 1.3, 0.15)
	tween.tween_property(self, "scale", original_scale, 0.15).set_delay(0.15)
	
	# Glow effect - fade in and out
	glow_effect.visible = true
	glow_effect.color = Color(0.2, 0.8, 1, 0)
	tween.tween_property(glow_effect, "color", Color(0.2, 0.8, 1, 0.6), 0.2)
	tween.tween_property(glow_effect, "color", Color(0.2, 0.8, 1, 0), 0.3).set_delay(0.2)
	
	# Brightness pulse on icon
	var original_modulate = icon.modulate
	tween.tween_property(icon, "modulate", Color(1.5, 1.5, 1.5, 1), 0.15)
	tween.tween_property(icon, "modulate", original_modulate, 0.25).set_delay(0.15)
	
	# Create particle burst effect
	_create_unlock_particles()
	
	# Play unlock sound (use Craft sound for unlock, more satisfying)
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.Craft)
	
	# Wait for animation to complete
	await tween.finished
	glow_effect.visible = false
	is_animating = false
	skill_unlock_animation_finished.emit()

func _create_unlock_particles() -> void:
	# Create simple particle-like effect using labels
	var particle_symbols = ["✨", "⭐", "💫"]
	for i in range(12):
		var particle = Label.new()
		particle.text = particle_symbols[i % particle_symbols.size()]
		particle.add_theme_font_size_override("font_size", 14 + randi() % 6)
		particle.position = Vector2(60, 60)  # Center of skill node
		particles_container.add_child(particle)
		
		# Animate particle
		var particle_tween = create_tween()
		var angle = (i / 12.0) * TAU
		var distance = 50.0 + randf() * 20.0
		var target_pos = Vector2(60, 60) + Vector2(cos(angle), sin(angle)) * distance
		
		particle_tween.set_parallel(true)
		particle_tween.tween_property(particle, "position", target_pos, 0.6)
		particle_tween.tween_property(particle, "modulate:a", 0.0, 0.6)
		particle_tween.tween_property(particle, "scale", Vector2(1.5, 1.5), 0.6)
		particle_tween.tween_callback(particle.queue_free).set_delay(0.6)
