extends CharacterBody3D

@export var normal_speed := 3.0
@export var sprint_speed := 5.0
@export var walking_energy_change_per_1m := -10.0
@export var jump_velocity := 4.0
@export var gravity := 0.2
@export var mouse_sensitivity := 0.005
@export var walking_footstep_audio_interval := 0.6
@export var sprinting_footstep_audio_interval := 0.3

@onready var head: Node3D = $Head
@onready var interaction_ray_cast: RayCast3D = $Head/InteractionRayCast
@onready var equippabel_item_holder: Node3D = %EquippabelItemHolder


func _enter_tree() -> void:
	EventSystem.PLA_frezze_player.connect(set_freeze.bind(true))
	EventSystem.PLA_unfrezze_player.connect(set_freeze.bind(false))


func set_freeze(freeze : bool) -> void:
	set_process(!freeze)
	set_physics_process(!freeze)
	set_process_input(!freeze)
	set_process_unhandled_key_input(!freeze)


func _process(_delta: float) -> void:
	interaction_ray_cast.check_interaction()



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	move()
	check_walking_energy_change(delta)
	
	if Input.is_action_just_pressed("Use"):
		equippabel_item_holder.try_to_use_item()


func move() -> void:
	var is_sprinting : bool
	
	if is_on_floor():
		is_sprinting = Input.is_action_pressed("Sprint")

		if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_velocity
			
	else:
		velocity.y -= gravity
		is_sprinting = false
	
	var speed := normal_speed if not is_sprinting else sprint_speed


	var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction := transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed

	move_and_slide()


func check_walking_energy_change(delta: float) -> void:
	if velocity.x or velocity.z:
		EventSystem.PLA_change_energy.emit(
			delta *
			walking_energy_change_per_1m *
			Vector2(velocity.x, velocity.z).length()
		)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_around(event.relative)


func look_around(relative : Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	head.rotate_x(-relative.y * mouse_sensitivity)
	head.rotation_degrees.x = clampf(head.rotation_degrees.x, -90, 90)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	elif event.is_action_pressed("Inventory"):
		EventSystem.BUL_create_bulletin.emit(BulletinConfig.Keys.CraftingMenu, null)

	elif event.is_action_pressed("ItemHotKeys"):
		EventSystem.EQU_hotkey_pressed.emit(int(event.as_text()))
