extends EquippableItem
class_name EquippableWeapon

@onready var hit_check_marker: Marker3D = $HitCheckMarker

var weapon_resource: WeaponResource

func _ready() -> void:
	if weapon_resource:
		hit_check_marker.position.z = -weapon_resource.attack_range

	super._ready()

func change_energy() -> void:
	EventSystem.PLA_change_energy.emit(weapon_resource.energy_change_per_use)

func check_hit() -> void:
	var space_state := get_world_3d().direct_space_state

	var ray_query_params := PhysicsRayQueryParameters3D.new()
	ray_query_params.collide_with_areas = true
	ray_query_params.collide_with_bodies = false
	ray_query_params.collision_mask = 8  # hitbox

	ray_query_params.from = global_position
	ray_query_params.to = hit_check_marker.global_position

	var result := space_state.intersect_ray(ray_query_params)

	if not result.is_empty():
		var collider = result.get("collider")
		var hit_position = result.get("position", Vector3.ZERO)
		
		if collider:
			collider.take_hit(weapon_resource)
			
			# Spawn hit particles - collider is a HitBox which has hit_particles_key property
			# Access the exported property directly
			var particles_key = collider.hit_particles_key
			EventSystem.SPA_spawn_vfx.emit(VFXConfig.get_vfx(particles_key), Transform3D(Basis(), hit_position))


func play_swoosh_audio() ->void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.WeaponSwoosh)
