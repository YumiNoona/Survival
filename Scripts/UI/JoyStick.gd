extends CanvasLayer

@onready var ring: TextureRect = $Ring
@onready var knob: TextureRect = $Knob
@onready var btn_move: Button = $BTN_Move
@onready var btn_sprint: Button = $BTN_Sprint
@onready var btn_swing: Button = $BTN_Swing
@onready var btn_consume: Button = $BTN_Consume
@onready var btn_place: Button = $BTN_Place
@onready var btn_pause: Button = $BTN_Pause

const FORCE_JOYSTICK = true

var joystick_active := false
var joystick_center := Vector2.ZERO
var joystick_radius := 75.0
var joystick_vector := Vector2.ZERO
var touch_index := -1

var camera_drag_active := false
var camera_drag_index := -1
var last_touch_position := Vector2.ZERO
var camera_sensitivity := 0.005

var player: Node3D = null
var item_holder: Node3D = null

func _ready() -> void:
	var is_mobile = OS.get_name() in ["Android", "iOS"] or FORCE_JOYSTICK
	
	if not is_mobile:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	visible = false
	joystick_radius = (ring.size.x - knob.size.x) / 2.0
	knob.position = ring.position + (ring.size - knob.size) / 2.0
	
	btn_move.button_down.connect(_on_move_button_down)
	btn_move.button_up.connect(_on_move_button_up)
	btn_sprint.pressed.connect(_on_sprint_pressed)
	btn_sprint.released.connect(_on_sprint_released)
	btn_swing.pressed.connect(_on_swing_pressed)
	btn_consume.pressed.connect(_on_consume_pressed)
	btn_place.pressed.connect(_on_place_pressed)
	btn_pause.pressed.connect(_on_pause_pressed)
	
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

func _on_move_button_up() -> void:
	joystick_active = false
	joystick_vector = Vector2.ZERO
	knob.position = ring.position + (ring.size - knob.size) / 2.0
	touch_index = -1

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventScreenTouch:
		var touch_event = event as InputEventScreenTouch
		
		if touch_event.pressed:
			var move_rect = btn_move.get_global_rect()
			if move_rect.has_point(touch_event.position) and touch_index < 0:
				touch_index = touch_event.index
				joystick_active = true
				joystick_center = ring.global_position + ring.size / 2.0
				var local_touch = ring.get_global_rect().position - touch_event.position
				local_touch = -local_touch
				knob.position = local_touch - knob.size / 2.0
			elif touch_index < 0 and camera_drag_index < 0:
				camera_drag_index = touch_event.index
				camera_drag_active = true
				last_touch_position = touch_event.position
		else:
			if touch_index == touch_event.index:
				joystick_active = false
				joystick_vector = Vector2.ZERO
				knob.position = Vector2.ZERO
				touch_index = -1
			elif camera_drag_index == touch_event.index:
				camera_drag_active = false
				camera_drag_index = -1
	
	elif event is InputEventScreenDrag:
		var drag_event = event as InputEventScreenDrag
		
		if joystick_active and touch_index == drag_event.index:
			var touch_pos = drag_event.position
			var relative = touch_pos - joystick_center
			var distance = relative.length()
			
			if distance > joystick_radius:
				relative = relative.normalized() * joystick_radius
			
			knob.position = relative - knob.size / 2.0
			joystick_vector = relative / joystick_radius
		
		elif camera_drag_active and camera_drag_index == drag_event.index:
			var delta = drag_event.relative
			if player:
				player.look_around(delta * camera_sensitivity)

static var joystick_input: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if not visible or not joystick_active:
		joystick_input = Vector2.ZERO
		return
	
	joystick_input = joystick_vector

func _on_sprint_pressed() -> void:
	Input.action_press("Sprint")

func _on_sprint_released() -> void:
	Input.action_release("Sprint")

func _on_swing_pressed() -> void:
	if item_holder:
		item_holder.try_to_use_item()

func _on_consume_pressed() -> void:
	if item_holder and item_holder.current_item_scene:
		if item_holder.current_item_scene is EquippableConsumable:
			var consumable = item_holder.current_item_scene as EquippableConsumable
			consumable.consume()

func _on_place_pressed() -> void:
	if item_holder and item_holder.current_item_scene:
		if item_holder.current_item_scene is EquippableConstructable:
			var constructable = item_holder.current_item_scene as EquippableConstructable
			constructable.try_to_construct()

func _on_pause_pressed() -> void:
	Input.action_press("ui_cancel")

func get_joystick_input() -> Vector2:
	return joystick_input

func _enter_tree() -> void:
	add_to_group("JoystickUI")
