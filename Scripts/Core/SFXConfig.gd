class_name SFXConfig

enum Keys {
	UIClick,
	ItemPickup,
	Craft,
	Build,
	Eat,
	WeaponSwoosh,
	TreeHit,
	BoulderHit,
	CowHurt,
	CowAttack,
	WolfHurt,
	WolfAttack,
	Footstep,
	JumpLand,
	GoInTent
}

const FILE_PATHS := {
	Keys.UIClick : "res://Assets/Audio/SFX/UI_Click.wav",
	Keys.ItemPickup : "res://Assets/Audio/SFX/ItemPickup.wav",
	Keys.Craft : "res://Assets/Audio/SFX/Craft.wav",
	Keys.Build : "res://Assets/Audio/SFX/Build.wav",
	Keys.Eat : "res://Assets/Audio/SFX/Eat.wav",
	Keys.WeaponSwoosh : "res://Assets/Audio/SFX/WeaponSwoosh.wav",
	Keys.TreeHit : "res://Assets/Audio/SFX/TreeHit.wav",
	Keys.BoulderHit : "res://Assets/Audio/SFX/BoulderHit.wav",
	Keys.CowHurt : "res://Assets/Audio/SFX/CowHurt.wav",
	Keys.CowAttack : "res://Assets/Audio/SFX/CowAttack.wav",
	Keys.WolfHurt : "res://Assets/Audio/SFX/WolfHurt.wav",
	Keys.WolfAttack : "res://Assets/Audio/SFX/WolfAttack.wav",
	Keys.Footstep : "res://Assets/Audio/SFX/Footstep.wav",
	Keys.JumpLand : "res://Assets/Audio/SFX/JumpLand.wav",
	Keys.GoInTent : "res://Assets/Audio/SFX/GoInTent.wav",
}

static func get_audio_stream(key:Keys) -> AudioStream:
	return load(FILE_PATHS.get(key))
