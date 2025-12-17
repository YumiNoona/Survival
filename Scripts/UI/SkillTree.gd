extends Bulletin
class_name SkillTree

@onready var title_label: Label = %Title
@onready var close_button: TextureButton = %CloseButton
@onready var xp_value_label: Label = %XPValue
@onready var combat_tab: Button = %CombatTab
@onready var survival_tab: Button = %SurvivalTab
@onready var crafting_tab: Button = %CraftingTab
@onready var exploration_tab: Button = %ExplorationTab
@onready var tree_canvas: Control = %TreeCanvas
@onready var connection_lines: Node2D = %ConnectionLines
@onready var skill_nodes: Node2D = %SkillNodes
@onready var description_title: Label = %DescriptionTitle
@onready var description_text: Label = %DescriptionText

@export var skill_node_scene: PackedScene

var current_category: SkillResource.SkillCategory = SkillResource.SkillCategory.COMBAT
var skill_node_instances: Dictionary = {}  
var connection_line_instances: Array[AnimatedSkillLine] = []
var _updating_lines := false

func _enter_tree() -> void:
	EventSystem.XP_xp_updated.connect(_on_xp_updated)
	EventSystem.SKL_skill_unlocked.connect(_on_skill_unlocked)

func _ready() -> void:
	EventSystem.PLA_freeze_player.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if close_button:
		close_button.pressed.connect(close)
	
	
	if combat_tab:
		combat_tab.pressed.connect(_on_category_selected.bind(SkillResource.SkillCategory.COMBAT))
	if survival_tab:
		survival_tab.pressed.connect(_on_category_selected.bind(SkillResource.SkillCategory.SURVIVAL))
	if crafting_tab:
		crafting_tab.pressed.connect(_on_category_selected.bind(SkillResource.SkillCategory.CRAFTING))
	if exploration_tab:
		exploration_tab.pressed.connect(_on_category_selected.bind(SkillResource.SkillCategory.EXPLORATION))
	

	load_skills_for_category(current_category)
	

	update_xp_display()
	
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _on_category_selected(category: SkillResource.SkillCategory) -> void:
	current_category = category
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
	load_skills_for_category(category)

func load_skills_for_category(category: SkillResource.SkillCategory) -> void:
	clear_skill_nodes()

	var skills = SkillConfig.get_skills_by_category(category)
	for skill in skills:
		create_skill_node(skill)
	draw_connection_lines()

func create_skill_node(skill: SkillResource) -> void:
	if not skill_node_scene:
		push_error("SkillNode scene not assigned!")
		return
	
	var skill_node: SkillNode = skill_node_scene.instantiate()
	skill_nodes.add_child(skill_node)
	skill_node.setup_skill(skill)
	skill_node.skill_node_clicked.connect(_on_skill_clicked)
	skill_node.skill_node_hovered.connect(_on_skill_hovered)
	
	skill_node_instances[skill.skill_key] = skill_node

func draw_connection_lines() -> void:
	if _updating_lines:
		return  # Prevent infinite recursion
	
	for line in connection_line_instances:
		if is_instance_valid(line):
			line.queue_free()
	connection_line_instances.clear()

	for skill_key in skill_node_instances.keys():
		var skill = SkillConfig.get_skill_resource(skill_key)
		if not skill:
			continue
		
		var to_node = skill_node_instances[skill_key]
		
		for prereq_key in skill.prerequisites:
			var from_node = skill_node_instances.get(prereq_key)
			if from_node:
				create_connection_line(from_node, to_node)

func create_connection_line(from_node: SkillNode, to_node: SkillNode) -> void:
	# Create animated line
	var animated_line = AnimatedSkillLine.new()
	
	# Get center positions of nodes (nodes are 120x120)
	var node_size = Vector2(120, 120)
	var from_pos = from_node.position + node_size / 2.0
	var to_pos = to_node.position + node_size / 2.0
	
	# Determine connection direction and adjust connection points
	var _direction = (to_pos - from_pos).normalized()
	
	# Connect from bottom of from_node to top of to_node (or side if horizontal)
	var vertical_distance = abs(to_pos.y - from_pos.y)
	var horizontal_distance = abs(to_pos.x - from_pos.x)
	
	if vertical_distance > horizontal_distance:
		# Vertical connection
		from_pos = from_node.position + Vector2(node_size.x / 2.0, node_size.y)
		to_pos = to_node.position + Vector2(node_size.x / 2.0, 0)
	else:
		# Horizontal connection
		if to_pos.x > from_pos.x:
			from_pos = from_node.position + Vector2(node_size.x, node_size.y / 2.0)
			to_pos = to_node.position + Vector2(0, node_size.y / 2.0)
		else:
			from_pos = from_node.position + Vector2(0, node_size.y / 2.0)
			to_pos = to_node.position + Vector2(node_size.x, node_size.y / 2.0)
	
	# Check if both nodes are unlocked to determine line color
	var from_unlocked = SkillTreeManager.is_skill_unlocked(from_node.skill_key)
	var to_unlocked = SkillTreeManager.is_skill_unlocked(to_node.skill_key)
	
	animated_line.setup_line(from_pos, to_pos, from_unlocked and to_unlocked)
	
	connection_lines.add_child(animated_line)
	connection_line_instances.append(animated_line)

func clear_skill_nodes() -> void:
	for child in skill_nodes.get_children():
		child.queue_free()
	skill_node_instances.clear()

func _on_skill_clicked(skill_key: String) -> void:
	var skill = SkillConfig.get_skill_resource(skill_key)
	if not skill:
		return

	if SkillTreeManager.try_unlock_skill(skill_key):
		update_all_skill_states()
		update_xp_display()
		# Update lines after unlocking
		update_line_animations()
	else:
		EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _on_skill_hovered(skill_key: String) -> void:
	var skill = SkillConfig.get_skill_resource(skill_key)
	if not skill:
		return
	
	description_title.text = skill.display_name
	description_text.text = skill.description + "\n\nXP Cost: " + str(skill.xp_cost)

	if skill.prerequisites.size() > 0:
		description_text.text += "\n\nPrerequisites:"
		for prereq_key in skill.prerequisites:
			var prereq = SkillConfig.get_skill_resource(prereq_key)
			if prereq:
				var unlocked = SkillTreeManager.is_skill_unlocked(prereq_key)
				var status = "✓" if unlocked else "✗"
				description_text.text += "\n" + status + " " + prereq.display_name

func update_all_skill_states() -> void:
	for skill_node in skill_node_instances.values():
		skill_node.update_skill_state()

func update_line_animations() -> void:
	if _updating_lines:
		return  # Prevent infinite recursion
	_updating_lines = true
	
	# Re-draw lines to update their unlock status
	draw_connection_lines()
	
	_updating_lines = false

func update_xp_display() -> void:
	xp_value_label.text = str(XPManager.available_xp)

func _on_xp_updated(_available: int, _total: int) -> void:
	update_xp_display()
	update_all_skill_states()

func _on_skill_unlocked(_skill_key: String) -> void:
	update_all_skill_states()
	update_xp_display()
	# Update lines when a skill is unlocked
	update_line_animations()

func close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.SkillTree)
	EventSystem.PLA_unfreeze_player.emit()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
