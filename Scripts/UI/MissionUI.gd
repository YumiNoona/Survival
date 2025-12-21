extends Control


@onready var mission_container: VBoxContainer = %MissionContainer

var current_inventory: Array = []

func _ready() -> void:
	EventSystem.MIS_mission_progress_updated.connect(_on_mission_progress_updated)
	EventSystem.MIS_mission_completed.connect(_on_mission_completed)
	EventSystem.INV_inventory_updated.connect(_on_inventory_updated)
	call_deferred("_initialize_missions")

func _initialize_missions() -> void:
	EventSystem.INV_ask_update_inventory.emit()
	_update_all_missions()

func _update_all_missions() -> void:
	for child in mission_container.get_children():
		child.queue_free()

	for mission_key in MissionManager.active_missions.keys():
		var mission = MissionManager.active_missions[mission_key]
		_create_mission_panel(mission, mission_key)

func _create_mission_panel(mission: MissionResource, mission_key: String) -> void:
	var panel = PanelContainer.new()
	var margin = MarginContainer.new()
	var vbox = VBoxContainer.new()
	var name_label = Label.new()
	var desc_label = Label.new()
	var objectives_vbox = VBoxContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.4, 1)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.name = mission_key
	panel.custom_minimum_size = Vector2(350, 0)
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(margin)
	margin.add_child(vbox)
	vbox.name = "Content"
	vbox.add_theme_constant_override("separation", 8)
	vbox.add_child(name_label)
	vbox.add_child(desc_label)
	vbox.add_child(objectives_vbox)
	name_label.text = mission.mission_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	desc_label.text = mission.mission_description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	objectives_vbox.name = "ObjectivesContainer"
	objectives_vbox.add_theme_constant_override("separation", 4)
	mission_container.add_child(panel)
	_update_objectives(mission, mission_key, objectives_vbox)

func _update_objectives(mission: MissionResource, mission_key: String, objectives_container: VBoxContainer) -> void:
	for child in objectives_container.get_children():
		objectives_container.remove_child(child)
		child.queue_free()
	
	var is_completed = MissionManager.is_mission_completed(mission_key)
	
	match mission.mission_type:
		MissionResource.MissionType.COLLECT_ITEMS:
			var progress = MissionManager.get_mission_progress(mission_key)
			for item_req in mission.required_items:
				if item_req is MissionRequirement:
					var item_id: int = item_req.item_id
					var required = item_req.amount
					var current = 0
					if progress.has(item_id) and progress[item_id].has("current"):
						current = progress[item_id]["current"]
					else:
						for inv_item_id in current_inventory:
							if inv_item_id == item_id:
								current += 1

					var item_res = ItemConfig.get_item_resource_by_id(item_id)
					if not item_res:
						continue 
					var item_name = item_res.display_name
					
					var obj_label = Label.new()
					if is_completed or current >= required:
						obj_label.text = "%s (%d/%d) ✓" % [item_name, required, required]
						obj_label.add_theme_color_override("font_color", Color(0.6, 1, 0.6, 1))
					else:
						obj_label.text = "%s (%d/%d)" % [item_name, current, required]
						obj_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
					
					obj_label.add_theme_font_size_override("font_size", 13)
					objectives_container.add_child(obj_label)
		
		MissionResource.MissionType.CRAFT_ITEM:
			var progress = MissionManager.get_mission_progress(mission_key)
			var item_name = ItemConfig.get_item_resource(mission.required_craft_item).display_name
			var crafted = progress.get("crafted", false)
			var current = 1 if crafted else 0
			
			var obj_label = Label.new()
			if is_completed or crafted:
				obj_label.text = "Craft %s (%d/1) ✓" % [item_name, current]
				obj_label.add_theme_color_override("font_color", Color(0.6, 1, 0.6, 1))
			else:
				obj_label.text = "Craft %s (%d/1)" % [item_name, current]
				obj_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
			
			obj_label.add_theme_font_size_override("font_size", 13)
			objectives_container.add_child(obj_label)
		
		MissionResource.MissionType.KILL_ENEMY:
			var progress = MissionManager.get_mission_progress(mission_key)
			var kills = progress.get("kills", 0)
			var required = progress.get("required", mission.required_kills)
			
			var obj_label = Label.new()
			if is_completed:
				obj_label.text = "Kill %d enemies (%d/%d) ✓" % [required, required, required]
				obj_label.add_theme_color_override("font_color", Color(0.6, 1, 0.6, 1))
			else:
				obj_label.text = "Kill %d enemies (%d/%d)" % [required, kills, required]
				obj_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
			
			obj_label.add_theme_font_size_override("font_size", 13)
			objectives_container.add_child(obj_label)
		
		MissionResource.MissionType.BUILD_STRUCTURE:
			var progress = MissionManager.get_mission_progress(mission_key)
			var structure_name = ItemConfig.get_item_resource(mission.required_structure).display_name
			var built = progress.get("built", false)
			var current = 1 if built else 0
			
			var obj_label = Label.new()
			if is_completed or built:
				obj_label.text = "Build %s (%d/1) ✓" % [structure_name, current]
				obj_label.add_theme_color_override("font_color", Color(0.6, 1, 0.6, 1))
			else:
				obj_label.text = "Build %s (%d/1)" % [structure_name, current]
				obj_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
			
			obj_label.add_theme_font_size_override("font_size", 13)
			objectives_container.add_child(obj_label)

func _on_inventory_updated(inventory: Array) -> void:
	current_inventory = inventory

func _on_mission_progress_updated(mission_key: String, _progress: Dictionary) -> void:
	var mission = MissionManager.active_missions.get(mission_key)
	if not mission:
		return

	var mission_panel = mission_container.get_node_or_null(mission_key)
	if mission_panel:
		var objectives_container = mission_panel.get_node_or_null("MarginContainer/Content/ObjectivesContainer")
		if not objectives_container:
			objectives_container = mission_panel.find_child("ObjectivesContainer", true, false)
		
		if objectives_container and objectives_container is VBoxContainer:
			_update_objectives(mission, mission_key, objectives_container)

func _on_mission_completed(mission_key: String, _mission: MissionResource) -> void:
	var mission_panel = mission_container.get_node_or_null(mission_key)
	if mission_panel:
		mission_panel.queue_free()
	call_deferred("_update_all_missions")
