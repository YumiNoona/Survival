extends Control
class_name SkillNode

@onready var icon: TextureRect = %Icon
@onready var skill_name_label: Label = %SkillName
@onready var xp_cost_label: Label = %XPCost
@onready var locked_overlay: ColorRect = %LockedOverlay
@onready var button: Button = %Button

var skill_resource: SkillResource
var skill_key: String = ""

signal skill_node_clicked(skill_key: String)
signal skill_node_hovered(skill_key: String)

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
	xp_cost_label.text = str(skill_resource.xp_cost) + " XP"
	
	# Update position
	position = skill_resource.position
	
	# Update state
	update_skill_state()

func update_skill_state() -> void:
	if not skill_resource:
		return
	
	var is_unlocked = SkillTreeManager.is_skill_unlocked(skill_key)
	var can_unlock = SkillTreeManager.can_unlock_skill(skill_key) if not is_unlocked else false
	
	if is_unlocked:
		# Unlocked state
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
