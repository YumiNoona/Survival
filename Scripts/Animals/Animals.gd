extends CharacterBody3D

const ANIM_BLEND_TIME := 0.2
const GRAVITY := 2.0


enum States {
	Idle,
	Wander,
	Dead,
	Flee,
	Hurt,
	Chase,
	Attack
}

var state := States.Idle


@onready var idle_timer: Timer = $Timers/IdleTimer
@onready var wander_timer: Timer = $Timers/WanderTimer
@onready var disappear_after_death_timer: Timer = $Timers/DisappearAfterDeathTimer
@onready var flee_timer: Timer = $Timers/FleeTimer
@onready var player:CharacterBody3D = get_tree().get_first_node_in_group("Player")

@onready var main_collision_shape: CollisionShape3D = $CollisionShape3D
@onready var meat_spawn_marker: Marker3D = $MeatSpawnMarker
@onready var eyes_marker: Marker3D = $EyesMarker
@onready var attack_hit_area: Area3D = $AttackHitArea
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var vision_area_collision_shape: CollisionShape3D = $VisionArea/CollisionShape3D

@export var normal_speed := 0.6
@export var alarmed_speed := 1.8
@export var max_health := 80.0
@export var meat_drop_count := 1 
@export var turn_speed_weight := 0.07
@export var min_idle_time := 2.0
@export var max_idle_time := 7.0
@export var min_wander_time := 2.0
@export var max_wander_time := 4.0
@export var flee_time := 3.0
@export var is_aggressive := false
@export var aggressive_after_hits := -1
@export var attack_distance = 2.0
@export var damage := 20.0
@export var vision_range := 15.0
@export var vision_fov := 80.0
@export var attack_audio_key := SFXConfig.Keys.WolfAttack
@export var attack_animation_name := "Attack_Headbutt"
@export var use_back_attack_kick := true  
@export var back_attack_angle := 90.0 
@export var idle_animations:Array[String] = []
@export var hurt_animations:Array[String] = []


var player_in_vision_range := false
var hit_count := 0
@onready var health := max_health


func _ready() -> void:
	animation_player.animation_finished.connect(animation_finished)
	vision_area_collision_shape.shape.radius = vision_range


func animation_finished(_anim_name : String) -> void:
	if state == States.Idle:
		if idle_animations.size() > 0:
			var anim_name = idle_animations.pick_random()
			if animation_player.has_animation(anim_name):
				animation_player.play(anim_name, ANIM_BLEND_TIME)
	
	elif state == States.Hurt:
		if not is_aggressive and not is_aggressive_after_hits():
			set_state(States.Flee)
		
		else:
			set_state(States.Chase)
	
	if state == States.Attack:
		set_state(States.Chase)


func _physics_process(_delta: float) -> void:
	if state == States.Idle:
		idle_loop()
	
	elif state == States.Wander:
		wander_loop()
	
	elif state == States.Flee:
		flee_loop()
	
	elif state == States.Chase:
		chase_loop()
	
	elif state == States.Attack:
		attack_loop()


func idle_loop() -> void:
	apply_gravity()
	if (is_aggressive or is_aggressive_after_hits()) and can_see_player():
		set_state(States.Chase)
		apply_gravity()


func wander_loop() -> void:
	look_forward()
	apply_gravity()
	move_and_slide()
	
	if (is_aggressive or is_aggressive_after_hits()) and can_see_player():
		set_state(States.Chase)


func flee_loop() -> void:
	look_forward()
	apply_gravity()
	move_and_slide()


func chase_loop() -> void:
	look_forward()
	if global_position.distance_to(player.global_position) < attack_distance:
		set_state(States.Attack)
		return
	
	nav_agent.target_position = player.global_position
	var dir := global_position.direction_to(nav_agent.get_next_path_position())
	dir.y = 0
	velocity.x = dir.normalized().x * alarmed_speed
	velocity.z = dir.normalized().z * alarmed_speed
	apply_gravity()
	move_and_slide()


func attack_loop() -> void:
	var dir = global_position.direction_to(player.global_position)
	rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z) + PI, turn_speed_weight)


func apply_gravity() -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY
	
	else:
		velocity.y = 0


func attack() -> void:
	if player in attack_hit_area.get_overlapping_bodies():
		EventSystem.PLA_change_health.emit(-damage)


func look_forward() -> void:
	rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z) + PI, turn_speed_weight)


func pick_wander_velocity() -> void:
	var dir := Vector2(0, -1).rotated(randf() * PI * 2)
	velocity = Vector3(dir.x, 0, dir.y) * normal_speed


func can_see_player() -> bool:
	return player_in_vision_range and player_in_fov() and player_in_los()


func player_in_fov() -> bool:
	if not player:
		return false
	
	var direction_to_player := global_position.direction_to(player.global_position)
	var forward := -global_transform.basis.z
	return direction_to_player.angle_to(forward) <= deg_to_rad(vision_fov)


func player_in_los() -> bool:
	if not player:
		return false
	
	var query_params := PhysicsRayQueryParameters3D.new()
	query_params.from = eyes_marker.global_position
	query_params.to = player.head.global_position + Vector3(0, 1.5, 0)
	query_params.collision_mask = 1 + 16 # environment
	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query_params)
	
	return result.is_empty()


func _on_idle_timer_timeout() -> void:
	set_state(States.Wander)


func _on_wander_timer_timeout() -> void:
	set_state(States.Idle)


func _on_disappear_after_death_timer_timeout() -> void:
	queue_free()


func _on_flee_timer_timeout() -> void:
	set_state(States.Idle)


func pick_away_from_player_velocity() -> void:
	if not player:
		set_state(States.Idle)
		return
	
	var dir := player.global_position.direction_to(global_position)
	dir.y = 0
	velocity = dir.normalized() * alarmed_speed


func set_state(new_state : States) -> void:
	state = new_state
	
	match state:
		States.Idle:
			idle_timer.start(randf_range(min_idle_time, max_idle_time))
			if idle_animations.size() > 0:
				var anim_name = idle_animations.pick_random()
				if animation_player.has_animation(anim_name):
					animation_player.play(anim_name, ANIM_BLEND_TIME)
		
		States.Wander:
			pick_wander_velocity()
			wander_timer.start(randf_range(min_wander_time, max_wander_time))
			animation_player.play("Walk", ANIM_BLEND_TIME)
		
		States.Hurt:
			idle_timer.stop()
			wander_timer.stop()
			flee_timer.stop()
			if hurt_animations.size() > 0:
				var anim_name = hurt_animations.pick_random()
				if animation_player.has_animation(anim_name):
					animation_player.play(anim_name, ANIM_BLEND_TIME)
		
		States.Flee:
			pick_away_from_player_velocity()
			animation_player.play("Gallop", ANIM_BLEND_TIME)
			flee_timer.start(flee_time)
		
		States.Chase:
			idle_timer.stop()
			wander_timer.stop()
			flee_timer.stop()
			animation_player.play("Gallop", ANIM_BLEND_TIME)
		
		States.Attack:
			var anim_to_play = get_attack_animation()
			if animation_player.has_animation(anim_to_play):
				animation_player.play(anim_to_play, ANIM_BLEND_TIME)
			else:
				# Fallback: try default attack animation
				if animation_player.has_animation(attack_animation_name):
					animation_player.play(attack_animation_name, ANIM_BLEND_TIME)
				elif animation_player.has_animation("Attack"):
					animation_player.play("Attack", ANIM_BLEND_TIME)
		
		States.Dead:
			idle_timer.stop()
			wander_timer.stop()
			flee_timer.stop()
			main_collision_shape.disabled = true
			animation_player.play("Death", ANIM_BLEND_TIME)
			spawn_meat()
			EventSystem.XP_award_xp.emit(15)
			set_physics_process(false)
			disappear_after_death_timer.start()


func play_attack_audio() -> void:
	EventSystem.SFX_play_dynamic_sfx.emit(attack_audio_key, global_position)


func take_hit(weapon_resource : WeaponResource) -> void:
	health -= weapon_resource.damage
	hit_count += 1
	
	if state != States.Dead and health <= 0:
		set_state(States.Dead)
	
	elif not state in [States.Flee, States.Dead]:
		set_state(States.Hurt)


func _on_vision_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_in_vision_range = true


func _on_vision_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_in_vision_range = false


func is_aggressive_after_hits() -> bool:
	if aggressive_after_hits <= 0:
		return false
	return hit_count >= aggressive_after_hits


func is_player_behind() -> bool:
	if not player:
		return false
	
	var direction_to_player := global_position.direction_to(player.global_position)
	var forward := -global_transform.basis.z
	forward.y = 0
	direction_to_player.y = 0
	forward = forward.normalized()
	direction_to_player = direction_to_player.normalized()
	var dot_product = forward.dot(direction_to_player)
	var angle = rad_to_deg(acos(clamp(dot_product, -1.0, 1.0)))
	return angle >= back_attack_angle


func get_attack_animation() -> String:
	if use_back_attack_kick and is_player_behind():
		if animation_player.has_animation("Attack_Kick"):
			return "Attack_Kick"
	return attack_animation_name


func spawn_meat() -> void:
	var meat_scene := ItemConfig.get_pickuppable_item(ItemConfig.Keys.RawMeat)
	
	for i in range(meat_drop_count):
		var offset := Vector3(
			randf_range(-0.3, 0.3),
			0.0,
			randf_range(-0.3, 0.3)
		)
		var spawn_transform := meat_spawn_marker.global_transform
		spawn_transform.origin += offset
		EventSystem.SPA_spawn_scene.emit(meat_scene, spawn_transform)
