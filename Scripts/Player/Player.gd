extends CharacterBody3D

@export var normal_speed := 3.0
@export var sprint_speed := 5.0
@export var walking_energy_change_per_1m := -0.08
@export var sprint_energy_multiplier := 2.0 
@export var jump_velocity := 4.0
@export var gravity := 0.2
@export var mouse_sensitivity := 0.005
@export var walking_footstep_audio_interval := 0.6
@export var sprinting_footstep_audio_interval := 0.3

@onready var head: Node3D = $Head
@onready var interaction_ray_cast: RayCast3D = $Head/InteractionRayCast
@onready var equippabel_item_holder: Node3D = %EquippabelItemHolder
@onready var footstep_audio_timer: Timer = $FootStepAudioTimer

var is_sprinting := false
var is_grounded := true
var can_double_jump := false
var has_double_jumped := false
var speed_modifier := 1.0

func _enter_tree() -> void:
	EventSystem.PLA_freeze_player.connect(set_freeze.bind(true))
	EventSystem.PLA_unfreeze_player.connect(set_freeze.bind(false))
	EventSystem.PLA_enable_double_jump.connect(_on_enable_double_jump)
	EventSystem.PLA_increase_movement_speed.connect(_on_increase_movement_speed)


func set_freeze(freeze : bool) -> void:
	set_process(!freeze)
	set_physics_process(!freeze)
	set_process_input(!freeze)
	set_process_unhandled_key_input(!freeze)


func _process(_delta: float) -> void:
	interaction_ray_cast.check_interaction()



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	EventSystem.HUD_show_hud.emit()


func _exit_tree() -> void:
	EventSystem.HUD_hide_hud.emit()


func _physics_process(delta: float) -> void:
	move()
	check_walking_energy_change(delta)
	
	if Input.is_action_just_pressed("Use"):
		equippabel_item_holder.try_to_use_item()


func move():
	if is_on_floor():
		is_sprinting = Input.is_action_pressed("Sprint")
		has_double_jumped = false 
		
		if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_velocity
		
		if velocity != Vector3.ZERO and footstep_audio_timer.is_stopped():
			EventSystem.SFX_play_dynamic_sfx.emit(SFXConfig.Keys.Footstep, global_position, 0.3)
			footstep_audio_timer.start(walking_footstep_audio_interval if not is_sprinting else sprinting_footstep_audio_interval)
		
		if not is_grounded:
			is_grounded = true
			EventSystem.SFX_play_dynamic_sfx.emit(SFXConfig.Keys.JumpLand, global_position)
	
	else:
		velocity.y -= gravity
		
		if is_grounded:
			is_grounded = false


		if can_double_jump and Input.is_action_just_pressed("Jump") and not has_double_jumped:
			velocity.y = jump_velocity
			has_double_jumped = true
	
	var speed := (normal_speed if not is_sprinting else sprint_speed) * speed_modifier
	var keyboard_input := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var joystick = get_tree().get_first_node_in_group("JoystickUI")
	var joystick_vec := Vector2.ZERO
	if joystick and joystick.has_method("get_joystick_input"):
		joystick_vec = joystick.get_joystick_input()
	var input_dir := keyboard_input if joystick_vec.length() < 0.1 else joystick_vec
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed
	
	move_and_slide()

func _on_enable_double_jump() -> void:
	can_double_jump = true

func _on_increase_movement_speed(percentage: int) -> void:
	speed_modifier += percentage / 100.0


func check_walking_energy_change(delta: float) -> void:
	var velocity_2d = Vector2(velocity.x, velocity.z)
	var movement_length = velocity_2d.length()


	if movement_length > 0.1:
		var energy_rate = walking_energy_change_per_1m
		
		if is_sprinting:
			energy_rate *= sprint_energy_multiplier
		
		EventSystem.PLA_change_energy.emit(
			delta *
			energy_rate *
			movement_length
		)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_around(event.relative)


func look_around(relative : Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	head.rotate_x(-relative.y * mouse_sensitivity)
	head.rotation_degrees.x = clampf(head.rotation_degrees.x, -90, 90)


func _toggle_bulletin(bulletin_key: BulletinConfig.Keys, extra_arg = null) -> void:
	var bulletin_controller = get_tree().root.find_child("BulletinController", true, false)
	
	if not bulletin_controller:
		EventSystem.BUL_create_bulletin.emit(bulletin_key, extra_arg)
		return


	var bulletin_exists = bulletin_controller.bulletins.has(bulletin_key) and \
						 is_instance_valid(bulletin_controller.bulletins.get(bulletin_key))
	
	if bulletin_exists:
		EventSystem.BUL_destroy_bulletin.emit(bulletin_key)
	else:
		EventSystem.BUL_create_bulletin.emit(bulletin_key, extra_arg)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
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

	elif event.is_action_pressed("Inventory"):
		_toggle_bulletin(BulletinConfig.Keys.CraftingMenu, null)

	elif event.is_action_pressed("ItemHotKeys"):
		EventSystem.EQU_hotkey_pressed.emit(int(event.as_text()))


	elif event.is_action_pressed("SkillTree"):
		_toggle_bulletin(BulletinConfig.Keys.SkillTree)
	
	elif event.is_action_pressed("Mission"):
		_toggle_bulletin(BulletinConfig.Keys.MissionMenu)
