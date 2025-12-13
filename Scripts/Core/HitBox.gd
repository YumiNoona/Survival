extends Area3D

signal register_hit(weapon_resource: WeaponResource)

func take_hit(weapon_resource: WeaponResource) -> void:
	register_hit.emit(weapon_resource)
