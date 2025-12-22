extends CanvasLayer

@onready var ring: TextureRect = $Ring
@onready var knob: TextureRect = $Knob
@onready var btn_move: Button = $BTN_Move
@onready var btn_use: Button = $BTN_Use
@onready var btn_pause: Button = $BTN_Pause

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
	
	EventSystem.HUD_show_hud.connect(_on_hud_shown)
	EventSystem.HUD_hide_hud.connect(_on_hud_hidden)

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
					camera_drag_active = false
					camera_drag_index = -1
					var ring_scaled_size = ring.size * ring.scale
					var center_global = ring.global_position + ring_scaled_size * 0.5
					var relative = mouse_event.position - center_global
					joystick_center = ring.position + ring_scaled_size * 0.5
					var distance = relative.length()
					if distance > joystick_radius:
						relative = relative.normalized() * joystick_radius
					knob.position = knob_center_position + relative
					joystick_vector = relative / joystick_radius
					get_viewport().set_input_as_handled()
				elif touch_index < 0 and camera_drag_index < 0 and not move_rect.has_point(mouse_event.position):
					camera_drag_index = 999
					camera_drag_active = true
					last_touch_position = mouse_event.position
			else:
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
				camera_drag_active = false
				camera_drag_index = -1
				var ring_scaled_size = ring.size * ring.scale
				var center_global = ring.global_position + ring_scaled_size * 0.5
				var relative = touch_event.position - center_global
				joystick_center = ring.position + ring_scaled_size * 0.5
				var distance = relative.length()
				if distance > joystick_radius:
					relative = relative.normalized() * joystick_radius
				knob.position = knob_center_position + relative
				joystick_vector = relative / joystick_radius
				get_viewport().set_input_as_handled()
			elif touch_index < 0 and camera_drag_index < 0 and not move_rect.has_point(touch_event.position):
				camera_drag_index = touch_event.index
				camera_drag_active = true
				last_touch_position = touch_event.position
		else:
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
				get_viewport().set_input_as_handled()
			
			elif camera_drag_active and camera_drag_index == 999 and not joystick_active:
				var move_rect = btn_move.get_global_rect()
				if not move_rect.has_point(mouse_event.position):
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
			get_viewport().set_input_as_handled()
		
		elif camera_drag_active and camera_drag_index == drag_event.index and not joystick_active:
			var move_rect = btn_move.get_global_rect()
			if not move_rect.has_point(drag_event.position):
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

func _on_btn_use_pressed() -> void:
	Input.action_press("Interact")
	Input.action_press("Use")
	await get_tree().process_frame
	Input.action_release("Interact")
	Input.action_release("Use")

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


func get_joystick_input() -> Vector2:
	return joystick_input

func _enter_tree() -> void:
	add_to_group("JoystickUI")
