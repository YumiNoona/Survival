extends Bulletin
class_name MissionMenu

@onready var main_mission_tab: Button = %MainMissionTab
@onready var sub_mission_tab: Button = %SubMissionTab
@onready var close_button: TextureButton = %CloseButton
@onready var mission_list_container: VBoxContainer = %MissionListVBox
@onready var quest_name_label: Label = %QuestName
@onready var description_label: Label = %DescriptionLabel
@onready var rewards_container: VBoxContainer = %RewardsContainer

var selected_mission_key: String = ""
var current_tab: int = 0  # 0 = Main Mission, 1 = Sub Mission

func _enter_tree() -> void:
	EventSystem.MIS_mission_progress_updated.connect(_on_mission_progress_updated)
	EventSystem.MIS_mission_completed.connect(_on_mission_completed)
	tree_exiting.connect(_on_tree_exiting)

func _ready() -> void:
	EventSystem.PLA_freeze_player.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if close_button:
		close_button.pressed.connect(close)
	
	if main_mission_tab:
		main_mission_tab.pressed.connect(_on_main_mission_tab_pressed)
	if sub_mission_tab:
		sub_mission_tab.pressed.connect(_on_sub_mission_tab_pressed)
	
	_update_mission_list()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _on_main_mission_tab_pressed() -> void:
	current_tab = 0
	_update_tab_styles()
	_update_mission_list()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _on_sub_mission_tab_pressed() -> void:
	current_tab = 1
	_update_tab_styles()
	_update_mission_list()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _update_tab_styles() -> void:
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	active_style.corner_radius_top_left = 8
	active_style.corner_radius_top_right = 8
	
	var inactive_style = StyleBoxFlat.new()
	inactive_style.bg_color = Color(0.15, 0.15, 0.2, 0.7)
	inactive_style.corner_radius_top_left = 8
	inactive_style.corner_radius_top_right = 8
	
	if main_mission_tab:
		if current_tab == 0:
			main_mission_tab.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			main_mission_tab.add_theme_stylebox_override("normal", active_style)
		else:
			main_mission_tab.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
			main_mission_tab.add_theme_stylebox_override("normal", inactive_style)
	
	if sub_mission_tab:
		if current_tab == 1:
			sub_mission_tab.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			sub_mission_tab.add_theme_stylebox_override("normal", active_style)
		else:
			sub_mission_tab.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
			sub_mission_tab.add_theme_stylebox_override("normal", inactive_style)

func _update_mission_list() -> void:
	_clear_mission_list()
	
	var all_missions = MissionConfig.get_all_missions()
	var displayed_missions: Array[Dictionary] = []
	
	# Filter missions by current tab
	for mission in all_missions:
		var mission_key = mission.mission_key
		var is_completed = MissionManager.is_mission_completed(mission_key)
		var is_active = MissionManager.is_mission_active(mission_key)
		
		# Filter by category
		var is_main_mission = mission.mission_category == MissionResource.MissionCategory.MAIN_MISSION
		if current_tab == 0 and not is_main_mission:
			continue
		if current_tab == 1 and is_main_mission:
			continue
		
		# Sort: active first, then completed
		var sort_order = 0 if is_active else 1
		displayed_missions.append({
			"mission": mission,
			"mission_key": mission_key,
			"is_completed": is_completed,
			"sort_order": sort_order
		})
	
	# Sort by status (active first)
	displayed_missions.sort_custom(func(a, b): return a["sort_order"] < b["sort_order"])
	
	# Create mission items
	for mission_data in displayed_missions:
		var mission = mission_data["mission"]
		var mission_key = mission_data["mission_key"]
		var is_completed = mission_data["is_completed"]
		_create_mission_item(mission, mission_key, mission_list_container, is_completed)
	
	# Select first mission if any exist
	if not mission_list_container.get_children().is_empty():
		var first_mission = mission_list_container.get_child(0)
		_on_mission_item_selected(first_mission.name)

func _clear_mission_list() -> void:
	for child in mission_list_container.get_children():
		child.queue_free()

func _create_mission_item(mission: MissionResource, mission_key: String, container: VBoxContainer, is_completed: bool) -> void:
	var mission_item = PanelContainer.new()
	mission_item.name = mission_key
	mission_item.custom_minimum_size = Vector2(0, 50)
	
	var style = StyleBoxFlat.new()
	if is_completed:
		style.bg_color = Color(0.08, 0.08, 0.08, 0.6)  # Grayed out for completed
	else:
		style.bg_color = Color(0.15, 0.15, 0.2, 0.9)  # Highlighted for active
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	mission_item.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	mission_item.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(hbox)
	
	# Mission icon (shield-like)
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(20, 20)
	if is_completed:
		icon.color = Color(0.4, 0.4, 0.4, 1)  # Gray for completed
	else:
		icon.color = Color(0.2, 1, 0.2, 1)  # Green for active
	hbox.add_child(icon)
	
	# Mission name
	var name_label = Label.new()
	name_label.text = mission.mission_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1) if not is_completed else Color(0.6, 0.6, 0.6, 1))
	hbox.add_child(name_label)
	
	# Checkmark if completed
	if is_completed:
		var checkmark = Label.new()
		checkmark.text = "✓"
		checkmark.add_theme_font_size_override("font_size", 18)
		checkmark.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		hbox.add_child(checkmark)
	
	# Make it clickable
	mission_item.gui_input.connect(_on_mission_item_gui_input.bind(mission_key))
	
	container.add_child(mission_item)

func _on_mission_item_gui_input(event: InputEvent, mission_key: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_mission_item_selected(mission_key)

func _on_mission_item_selected(mission_key: String) -> void:
	selected_mission_key = mission_key
	var mission = MissionConfig.get_mission_resource(mission_key)
	if not mission:
		return
	
	# Update quest name
	quest_name_label.text = mission.mission_name
	
	# Update description
	description_label.text = mission.mission_description
	
	# Update rewards
	_update_rewards(mission)

func _update_rewards(mission: MissionResource) -> void:
	# Clear existing rewards
	for child in rewards_container.get_children():
		child.queue_free()
	
	# XP Reward
	var reward_hbox = HBoxContainer.new()
	reward_hbox.add_theme_constant_override("separation", 8)
	
	var xp_icon = ColorRect.new()
	xp_icon.custom_minimum_size = Vector2(16, 16)
	xp_icon.color = Color(0.2, 0.8, 1, 1)
	reward_hbox.add_child(xp_icon)
	
	var xp_label = Label.new()
	xp_label.text = "EXP +%d" % mission.xp_reward
	xp_label.add_theme_font_size_override("font_size", 16)
	xp_label.add_theme_color_override("font_color", Color(0.2, 1, 0.2, 1))
	reward_hbox.add_child(xp_label)
	
	rewards_container.add_child(reward_hbox)

func _on_mission_progress_updated(_mission_key: String, _progress: Dictionary) -> void:
	# Objectives are now handled in MissionUI (HUD)
	pass

func _on_mission_completed(_mission_key: String, _mission: MissionResource) -> void:
	call_deferred("_update_mission_list")

func _on_tree_exiting() -> void:
	# Cleanup when bulletin is being destroyed (whether via close() or direct destruction)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.PLA_unfreeze_player.emit()

func close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.MissionMenu)
	EventSystem.PLA_unfreeze_player.emit()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
