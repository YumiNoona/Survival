extends Area3D

signal register_hit(weapon_resource: WeaponResource)

@export var hit_audio_key := SFXConfig.Keys.TreeHit
@export var hit_particles_key := VFXConfig.Keys.HitParticlesWood

func take_hit(weapon_resource: WeaponResource) -> void:
	register_hit.emit(weapon_resource)
	EventSystem.SFX_play_dynamic_sfx.emit(hit_audio_key, global_position)
