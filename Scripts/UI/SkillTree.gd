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
@onready var tree_area: PanelContainer = %TreeArea

@export var skill_node_scene: PackedScene

var current_category: SkillResource.SkillCategory = SkillResource.SkillCategory.COMBAT
var skill_node_instances: Dictionary = {}  
var connection_line_instances: Array[AnimatedSkillLine] = []
var _updating_lines := false


func _enter_tree() -> void:
	EventSystem.XP_xp_updated.connect(_on_xp_updated)
	EventSystem.SKL_skill_unlocked.connect(_on_skill_unlocked)
	tree_exiting.connect(_on_tree_exiting)

func _ready() -> void:
	EventSystem.PLA_freeze_player.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if close_button:
		close_button.pressed.connect(close)
	
	
	if combat_tab:
		combat_tab.pressed.connect(Callable(self, "_on_combat_tab_pressed"))
	if survival_tab:
		survival_tab.pressed.connect(Callable(self, "_on_survival_tab_pressed"))
	if crafting_tab:
		crafting_tab.pressed.connect(Callable(self, "_on_crafting_tab_pressed"))
	if exploration_tab:
		exploration_tab.pressed.connect(Callable(self, "_on_exploration_tab_pressed"))
	

	load_skills_for_category(current_category)
	

	update_xp_display()
	
	# Reset canvas scale to ensure proper clicking
	if tree_canvas:
		tree_canvas.scale = Vector2(1.0, 1.0)
	
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)

func _on_combat_tab_pressed() -> void:
	_on_category_selected(SkillResource.SkillCategory.COMBAT)

func _on_survival_tab_pressed() -> void:
	_on_category_selected(SkillResource.SkillCategory.SURVIVAL)

func _on_crafting_tab_pressed() -> void:
	_on_category_selected(SkillResource.SkillCategory.CRAFTING)

func _on_exploration_tab_pressed() -> void:
	_on_category_selected(SkillResource.SkillCategory.EXPLORATION)

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
	
	# Get center positions of nodes (nodes are now 180x180)
	var node_size = Vector2(180, 180)
	var from_center = from_node.position + node_size / 2.0
	var to_center = to_node.position + node_size / 2.0
	
	# Determine connection direction and adjust connection points
	var _direction = (to_center - from_center).normalized()
	var vertical_distance = abs(to_center.y - from_center.y)
	var horizontal_distance = abs(to_center.x - from_center.x)
	
	# Declare connection points
	var from_pos: Vector2
	var to_pos: Vector2
	
	# Calculate connection points centered on button edges
	if vertical_distance > horizontal_distance:
		# Vertical connection - connect from bottom center to top center
		from_pos = from_node.position + Vector2(node_size.x / 2.0, node_size.y)
		to_pos = to_node.position + Vector2(node_size.x / 2.0, 0)
	else:
		# Horizontal connection - connect from side center to side center
		if to_center.x > from_center.x:
			# From right center to left center
			from_pos = from_node.position + Vector2(node_size.x, node_size.y / 2.0)
			to_pos = to_node.position + Vector2(0, node_size.y / 2.0)
		else:
			# From left center to right center
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
		# Play unlock animation on the skill node
		var skill_node = skill_node_instances.get(skill_key)
		if skill_node:
			skill_node.play_unlock_animation()
			await skill_node.skill_unlock_animation_finished
		
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
	
	var current_level = SkillTreeManager.get_skill_level(skill_key)
	var next_level = current_level + 1
	var can_upgrade = SkillTreeManager.can_unlock_skill(skill_key)
	var is_unlocked = current_level > 0
	
	# Title with category and level
	var category_name = _get_category_name(skill.category)
	description_title.text = "[%s] %s" % [category_name, skill.display_name]
	if skill.max_level > 1:
		description_title.text += " (Level %d/%d)" % [current_level, skill.max_level]
	
	var desc = ""
	
	# Status indicator
	if current_level >= skill.max_level:
		desc += "✓ MAX LEVEL\n"
	elif is_unlocked:
		desc += "✓ UNLOCKED\n"
	elif can_upgrade:
		desc += "● AVAILABLE\n"
	else:
		desc += "✗ LOCKED\n"
	
	desc += "\n" + skill.description
	
	# Show all level effects if multi-level skill
	if skill.max_level > 1:
		desc += "\n\n━━━ All Levels ━━━"
		for level in range(1, skill.max_level + 1):
			var level_value = SkillTreeManager.get_value_for_level(skill, level)
			var level_xp = SkillTreeManager.get_xp_cost_for_level(skill, level)
			var level_marker = ""
			if level == current_level:
				level_marker = " [CURRENT]"
			elif level < current_level:
				level_marker = " [UNLOCKED]"
			desc += "\nLevel %d: %s (%d XP)%s" % [level, _format_skill_effect(skill, level_value), level_xp, level_marker]
	
	# XP Information
	desc += "\n\n━━━ Cost ━━━"
	if can_upgrade:
		var xp_cost = SkillTreeManager.get_xp_cost_for_level(skill, next_level)
		desc += "\nNext Level: %d XP" % xp_cost
		if XPManager.available_xp >= xp_cost:
			desc += " ✓ (You have %d XP)" % XPManager.available_xp
		else:
			desc += " ✗ (Need %d more XP)" % (xp_cost - XPManager.available_xp)
	elif current_level >= skill.max_level:
		desc += "\nMAX LEVEL - No further upgrades"
	else:
		desc += "\nBase Cost: %d XP" % skill.xp_cost
		if not can_upgrade:
			var xp_cost = SkillTreeManager.get_xp_cost_for_level(skill, 1)
			if XPManager.available_xp < xp_cost:
				desc += "\n✗ Insufficient XP (Need %d, have %d)" % [xp_cost, XPManager.available_xp]
	
	# Total XP invested (if unlocked)
	if is_unlocked:
		var total_xp_invested = 0
		for level in range(1, current_level + 1):
			total_xp_invested += SkillTreeManager.get_xp_cost_for_level(skill, level)
		desc += "\nTotal Invested: %d XP" % total_xp_invested
	
	# Show stats preview (before/after)
	if has_node("/root/PlayerStatsTracker") and can_upgrade:
		var stats_tracker = get_node("/root/PlayerStatsTracker")
		var current_stats = stats_tracker.get_current_stats()
		var future_stats = stats_tracker.calculate_stats_after_skill(skill, next_level)
		
		var stats_changes = _get_stats_changes(current_stats, future_stats, skill)
		if stats_changes != "":
			desc += "\n\n━━━ Stats Preview ━━━"
			desc += stats_changes
	
	# Prerequisites with detailed status
	if skill.prerequisites.size() > 0:
		desc += "\n\n━━━ Prerequisites ━━━"
		var all_prereqs_met = true
		for prereq_key in skill.prerequisites:
			var prereq = SkillConfig.get_skill_resource(prereq_key)
			if prereq:
				var unlocked = SkillTreeManager.is_skill_unlocked(prereq_key)
				var status = "✓" if unlocked else "✗"
				desc += "\n%s %s" % [status, prereq.display_name]
				if not unlocked:
					all_prereqs_met = false
		
		if not all_prereqs_met and current_level == 0:
			desc += "\n\n✗ Missing prerequisites required to unlock"
	
	# Lock reason if can't unlock
	if not can_upgrade and current_level == 0:
		var lock_reasons = []
		if skill.prerequisites.size() > 0:
			for prereq_key in skill.prerequisites:
				if not SkillTreeManager.is_skill_unlocked(prereq_key):
					var prereq = SkillConfig.get_skill_resource(prereq_key)
					if prereq:
						lock_reasons.append("Requires: " + prereq.display_name)
		
		var xp_cost = SkillTreeManager.get_xp_cost_for_level(skill, 1)
		if XPManager.available_xp < xp_cost:
			lock_reasons.append("Need %d more XP" % (xp_cost - XPManager.available_xp))
		
		if lock_reasons.size() > 0:
			desc += "\n\n━━━ Locked ━━━"
			for reason in lock_reasons:
				desc += "\n• " + reason
	
	description_text.text = desc

func _get_category_name(category: SkillResource.SkillCategory) -> String:
	match category:
		SkillResource.SkillCategory.COMBAT:
			return "COMBAT"
		SkillResource.SkillCategory.SURVIVAL:
			return "SURVIVAL"
		SkillResource.SkillCategory.CRAFTING:
			return "CRAFTING"
		SkillResource.SkillCategory.EXPLORATION:
			return "EXPLORATION"
		_:
			return "UNKNOWN"

func _get_stats_changes(current: Dictionary, future: Dictionary, _skill: SkillResource) -> String:
	var changes = ""
	
	# Health
	if future["max_health"] != current["max_health"]:
		var change = future["max_health"] - current["max_health"]
		changes += "\nHealth: %.0f → %.0f (+%.0f)" % [current["max_health"], future["max_health"], change]
	
	# Energy
	if future["max_energy"] != current["max_energy"]:
		var change = future["max_energy"] - current["max_energy"]
		changes += "\nEnergy: %.0f → %.0f (+%.0f)" % [current["max_energy"], future["max_energy"], change]
	
	# Movement Speed
	if abs(future["movement_speed_modifier"] - current["movement_speed_modifier"]) > 0.001:
		var current_percent = (current["movement_speed_modifier"] - 1.0) * 100.0
		var future_percent = (future["movement_speed_modifier"] - 1.0) * 100.0
		var change = future_percent - current_percent
		changes += "\nSpeed: +%.0f%% → +%.0f%% (+%.0f%%)" % [current_percent, future_percent, change]
	
	# Attack Damage
	if abs(future["attack_damage_modifier"] - current["attack_damage_modifier"]) > 0.001:
		var current_percent = (current["attack_damage_modifier"] - 1.0) * 100.0
		var future_percent = (future["attack_damage_modifier"] - 1.0) * 100.0
		var change = future_percent - current_percent
		changes += "\nDamage: +%.0f%% → +%.0f%% (+%.0f%%)" % [current_percent, future_percent, change]
	
	# Inventory Slots
	if future["inventory_slots"] != current["inventory_slots"]:
		var change = future["inventory_slots"] - current["inventory_slots"]
		changes += "\nInventory: %d → %d slots (+%d)" % [current["inventory_slots"], future["inventory_slots"], change]
	
	# Double Jump
	if future["has_double_jump"] and not current["has_double_jump"]:
		changes += "\nDouble Jump: ✗ → ✓"
	
	return changes

func _format_skill_effect(skill: SkillResource, value: int) -> String:
	match skill.unlock_type:
		SkillResource.UnlockType.INVENTORY_SLOTS:
			return "+%d Inventory Slots" % value
		SkillResource.UnlockType.MOVEMENT_SPEED:
			return "+%d%% Movement Speed" % value
		SkillResource.UnlockType.HEALTH_BONUS:
			return "+%d Max Health" % value
		SkillResource.UnlockType.ENERGY_BONUS:
			return "+%d Max Energy" % value
		SkillResource.UnlockType.ATTACK_DAMAGE:
			return "+%d%% Attack Damage" % value
		_:
			return "Effect: %d" % value

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


func _on_tree_exiting() -> void:
	# Cleanup when bulletin is being destroyed (whether via close() or direct destruction)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.PLA_unfreeze_player.emit()

func close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.SkillTree)
	EventSystem.PLA_unfreeze_player.emit()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
