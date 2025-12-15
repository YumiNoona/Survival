class_name VFXConfig

enum Keys {
	HitParticlesWood,
	HitParticlesStone,
	HitParticlesBlood
}

const FILE_PATHS := {
	Keys.HitParticlesWood : "res://Scenes/Particles/HitParticlesWood.tscn",
	Keys.HitParticlesStone : "res://Scenes/Particles/HitParticlesStone.tscn",
	Keys.HitParticlesBlood : "res://Scenes/Particles/HitParticlesBlood.tscn",
}

static func get_vfx(key:Keys) -> PackedScene:
	return load(FILE_PATHS.get(key))
