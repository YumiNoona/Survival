extends CanvasLayer

@onready var ring: TextureRect = $Ring
@onready var knob: TextureRect = $Knob
@onready var btn_move: Button = $BTN_Move
@onready var btn_sprint: Button = $BTN_Sprint
@onready var btn_swing: Button = $BTN_Swing
@onready var btn_consume: Button = $BTN_Consume
@onready var btn_place: Button = $BTN_Place
@onready var btn_pause: Button = $BTN_Pause
@onready var btn_inventory: Button = $BTN_Inventory
@onready var btn_skills: Button = $BTN_Skills
@onready var btn_mission: Button = $BTN_Mission

const FORCE_JOYSTICK = true

var debug_show_cursor := true

var joystick_active := false
var joystick_center := Vector2.ZERO
var joystick_radius := 75.0
var joystick_vector := Vector2.ZERO
var touch_index := -1
var knob_center_position := Vector2.ZERO

var camera_drag_active := false
var camera_drag_index := -1
var last_touch_position := Vector2.ZERO
var camera_sensitivity := 0.005

var player: Node3D = null
var item_holder: Node3D = null

func _ready() -> void:
	var is_actual_mobile = OS.get_name() in ["Android", "iOS"]
	var _is_mobile = is_actual_mobile or FORCE_JOYSTICK
	
	visible = false
	var ring_scaled_size = ring.size * ring.scale
	var knob_scaled_size = knob.size * knob.scale
	joystick_radius = (ring_scaled_size.x - knob_scaled_size.x) / 2.0
	joystick_center = ring.position + ring_scaled_size * 0.5
	knob_center_position = ring.position + (ring_scaled_size - knob_scaled_size) / 2.0
	knob.position = knob_center_position
	
	btn_move.button_down.connect(_on_move_button_down)
	btn_move.button_up.connect(_on_move_button_up)
	btn_sprint.pressed.connect(_on_sprint_pressed)
	btn_sprint.button_up.connect(_on_sprint_released)
	
	EventSystem.HUD_show_hud.connect(_on_hud_shown)
	EventSystem.HUD_hide_hud.connect(_on_hud_hidden)
	EventSystem.EQU_equip_item.connect(_on_item_equipped)
	EventSystem.EQU_unequip_item.connect(_on_item_unequipped)
	
	_update_button_visibility()

func _on_hud_shown() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("Player")
	if player:
		item_holder = player.get_node_or_null("EquippabelItemHolder")
	await get_tree().process_frame
	var ring_scaled_size = ring.size * ring.scale
	var knob_scaled_size = knob.size * knob.scale
	joystick_radius = (ring_scaled_size.x - knob_scaled_size.x) / 2.0
	joystick_center = ring.position + ring_scaled_size * 0.5
	knob_center_position = ring.position + (ring_scaled_size - knob_scaled_size) / 2.0
	knob.position = knob_center_position
	var is_actual_mobile = OS.get_name() in ["Android", "iOS"]
	if debug_show_cursor and not is_actual_mobile:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true

func _on_hud_hidden() -> void:
	visible = false
	joystick_active = false
	joystick_vector = Vector2.ZERO
	camera_drag_active = false

func _on_item_equipped(_item_key: ItemConfig.Keys) -> void:
	_update_button_visibility()

func _on_item_unequipped() -> void:
	_update_button_visibility()

func _update_button_visibility() -> void:
	if not player or not item_holder:
		btn_swing.visible = false
		btn_consume.visible = false
		btn_place.visible = false
		return
	
	var current_item = item_holder.current_item_scene
	if not current_item:
		btn_swing.visible = false
		btn_consume.visible = false
		btn_place.visible = false
		return
	
	var is_weapon = current_item is EquippableWeapon
	var is_consumable = current_item is EquippableConsumable
	var is_constructable = current_item is EquippableConstructable
	
	btn_swing.visible = is_weapon
	btn_consume.visible = is_consumable
	btn_place.visible = is_constructable

func _on_move_button_down() -> void:
	if touch_index >= 0:
		return
	touch_index = 0
	joystick_active = true
	var ring_scaled_size = ring.size * ring.scale
	joystick_center = ring.position + ring_scaled_size * 0.5

func _on_move_button_up() -> void:
	joystick_active = false
	joystick_vector = Vector2.ZERO
	knob.position = knob_center_position
	touch_index = -1

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		var is_actual_mobile = OS.get_name() in ["Android", "iOS"]
		
		if not is_actual_mobile and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				var move_rect = btn_move.get_global_rect()
				if move_rect.has_point(mouse_event.position) and touch_index < 0:
					touch_index = 999
					joystick_active = true
					var ring_scaled_size = ring.size * ring.scale
					var center_global = ring.global_position + ring_scaled_size * 0.5
					var relative = mouse_event.position - center_global
					joystick_center = ring.position + ring_scaled_size * 0.5
					var distance = relative.length()
					if distance > joystick_radius:
						relative = relative.normalized() * joystick_radius
					knob.position = knob_center_position + relative
					joystick_vector = relative / joystick_radius
				elif touch_index < 0 and camera_drag_index < 0:
					camera_drag_index = 999
					camera_drag_active = true
					last_touch_position = mouse_event.position
			else:
				if btn_sprint and btn_sprint.visible:
					var btn_rect = btn_sprint.get_global_rect()
					if btn_rect.has_point(mouse_event.position):
						btn_sprint.emit_signal("button_up")
						get_viewport().set_input_as_handled()
						return
				
				if touch_index == 999:
					joystick_active = false
					joystick_vector = Vector2.ZERO
					knob.position = knob_center_position
					touch_index = -1
				elif camera_drag_index == 999:
					camera_drag_active = false
					camera_drag_index = -1
	
	if event is InputEventScreenTouch:
		var touch_event = event as InputEventScreenTouch
		
		if touch_event.pressed:
			var move_rect = btn_move.get_global_rect()
			if move_rect.has_point(touch_event.position) and touch_index < 0:
				touch_index = touch_event.index
				joystick_active = true
				var ring_scaled_size = ring.size * ring.scale
				var center_global = ring.global_position + ring_scaled_size * 0.5
				var relative = touch_event.position - center_global
				joystick_center = ring.position + ring_scaled_size * 0.5
				var distance = relative.length()
				if distance > joystick_radius:
					relative = relative.normalized() * joystick_radius
				knob.position = knob_center_position + relative
				joystick_vector = relative / joystick_radius
			elif touch_index < 0 and camera_drag_index < 0:
				camera_drag_index = touch_event.index
				camera_drag_active = true
				last_touch_position = touch_event.position
		else:
			if btn_sprint and btn_sprint.visible:
				var btn_rect = btn_sprint.get_global_rect()
				if btn_rect.has_point(touch_event.position):
					btn_sprint.emit_signal("button_up")
					get_viewport().set_input_as_handled()
					return
			
			if touch_index == touch_event.index:
				joystick_active = false
				joystick_vector = Vector2.ZERO
				knob.position = knob_center_position
				touch_index = -1
			elif camera_drag_index == touch_event.index:
				camera_drag_active = false
				camera_drag_index = -1
	
	elif event is InputEventMouseMotion:
		var is_actual_mobile = OS.get_name() in ["Android", "iOS"]
		if not is_actual_mobile and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_event = event as InputEventMouseMotion
			
			if joystick_active and touch_index == 999:
				var ring_scaled_size = ring.size * ring.scale
				var center_global = ring.global_position + ring_scaled_size * 0.5
				var relative = mouse_event.position - center_global
				var distance = relative.length()
				
				if distance > joystick_radius:
					relative = relative.normalized() * joystick_radius
				
				knob.position = knob_center_position + relative
				joystick_vector = relative / joystick_radius
			
			elif camera_drag_active and camera_drag_index == 999:
				var delta = mouse_event.relative
				if player:
					player.look_around(delta * camera_sensitivity)
	
	elif event is InputEventScreenDrag:
		var drag_event = event as InputEventScreenDrag
		
		if joystick_active and touch_index == drag_event.index:
			var ring_scaled_size = ring.size * ring.scale
			var center_global = ring.global_position + ring_scaled_size * 0.5
			var relative = drag_event.position - center_global
			var distance = relative.length()
			
			if distance > joystick_radius:
				relative = relative.normalized() * joystick_radius
			
			knob.position = knob_center_position + relative
			joystick_vector = relative / joystick_radius
		
		elif camera_drag_active and camera_drag_index == drag_event.index:
			var delta = drag_event.relative
			if player:
				player.look_around(delta * camera_sensitivity)

static var joystick_input: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	var is_actual_mobile = OS.get_name() in ["Android", "iOS"]
	if debug_show_cursor and not is_actual_mobile and visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if not visible or not joystick_active:
		joystick_input = Vector2.ZERO
		return
	
	joystick_input = joystick_vector

func _on_sprint_pressed() -> void:
	Input.action_press("Sprint")

func _on_sprint_released() -> void:
	Input.action_release("Sprint")

func _on_btn_sprint_pressed() -> void:
	Input.action_press("Sprint")

func _on_btn_swing_pressed() -> void:
	if item_holder:
		item_holder.try_to_use_item()

func _on_btn_consume_pressed() -> void:
	if item_holder and item_holder.current_item_scene:
		if item_holder.current_item_scene is EquippableConsumable:
			var consumable = item_holder.current_item_scene as EquippableConsumable
			consumable.consume()

func _on_btn_place_pressed() -> void:
	if item_holder and item_holder.current_item_scene:
		if item_holder.current_item_scene is EquippableConstructable:
			var constructable = item_holder.current_item_scene as EquippableConstructable
			constructable.try_to_construct()

func _on_btn_pause_pressed() -> void:
	var bulletin_controller = get_tree().root.find_child("BulletinController", true, false)
	if not bulletin_controller:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)
		return
	
	var bulletin_exists = bulletin_controller.bulletins.has(BulletinConfig.Keys.PauseMenu) and \
						 is_instance_valid(bulletin_controller.bulletins.get(BulletinConfig.Keys.PauseMenu))
	
	if bulletin_exists:
		EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.PauseMenu)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.PauseMenu)

func _on_btn_inventory_pressed() -> void:
	var bulletin_controller = get_tree().root.find_child("BulletinController", true, false)
	if not bulletin_controller:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.CraftingMenu, null)
		return
	
	var bulletin_exists = bulletin_controller.bulletins.has(BulletinConfig.Keys.CraftingMenu) and \
						 is_instance_valid(bulletin_controller.bulletins.get(BulletinConfig.Keys.CraftingMenu))
	
	if bulletin_exists:
		EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.CraftingMenu)
	else:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.CraftingMenu, null)

func _on_btn_skills_pressed() -> void:
	var bulletin_controller = get_tree().root.find_child("BulletinController", true, false)
	if not bulletin_controller:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SkillTree)
		return
	
	var bulletin_exists = bulletin_controller.bulletins.has(BulletinConfig.Keys.SkillTree) and \
						 is_instance_valid(bulletin_controller.bulletins.get(BulletinConfig.Keys.SkillTree))
	
	if bulletin_exists:
		EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.SkillTree)
	else:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.SkillTree)

func _on_btn_mission_pressed() -> void:
	var bulletin_controller = get_tree().root.find_child("BulletinController", true, false)
	if not bulletin_controller:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.MissionMenu)
		return
	
	var bulletin_exists = bulletin_controller.bulletins.has(BulletinConfig.Keys.MissionMenu) and \
						 is_instance_valid(bulletin_controller.bulletins.get(BulletinConfig.Keys.MissionMenu))
	
	if bulletin_exists:
		EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.MissionMenu)
	else:
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.MissionMenu)

func get_joystick_input() -> Vector2:
	return joystick_input

func _enter_tree() -> void:
	add_to_group("JoystickUI")
