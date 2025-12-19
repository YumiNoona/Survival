extends Control
class_name SkillUnlockNotification

@onready var icon_texture: TextureRect = %Icon
@onready var title_label: Label = %Title
@onready var description_label: Label = %Description
@onready var level_label: Label = %LevelLabel

var skill_key: String = ""
var auto_dismiss_timer: Timer

const DISPLAY_TIME: float = 4.0
const FADE_TIME: float = 0.3

var skill_data_set: bool = false

func _ready() -> void:
	# Create auto-dismiss timer
	auto_dismiss_timer = Timer.new()
	auto_dismiss_timer.wait_time = DISPLAY_TIME
	auto_dismiss_timer.one_shot = true
	auto_dismiss_timer.timeout.connect(_on_auto_dismiss)
	add_child(auto_dismiss_timer)
	
	

	if skill_key != "" and not skill_data_set:
		_setup_skill_data()
	fade_in()
	auto_dismiss_timer.start()

func setup_notification(_skill_key: String) -> void:
	skill_key = _skill_key
	if is_node_ready():
		_setup_skill_data()

func _setup_skill_data() -> void:
	if skill_data_set:
		return
	
	var skill_resource = SkillConfig.get_skill_resource(skill_key)
	if not skill_resource:
		return
	
	skill_data_set = true
	

	if skill_resource.icon and icon_texture:
		icon_texture.texture = skill_resource.icon
	else:
		icon_texture.texture = null
	

	if title_label:
		title_label.text = "Skill Unlocked!"
	
	# Set skill name and description
	if description_label:
		var _level = SkillTreeManager.get_skill_level(skill_key)
		description_label.text = skill_resource.display_name
	

	if level_label:
		var level = SkillTreeManager.get_skill_level(skill_key)
		if skill_resource.max_level > 1:
			level_label.text = "Level %d/%d" % [level, skill_resource.max_level]
			level_label.visible = true
		else:
			level_label.visible = false

func fade_in() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(queue_free)

func _on_auto_dismiss() -> void:
	fade_out()

func _on_close_pressed() -> void:
	fade_out()

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SkillTree)
		fade_out()
		EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
