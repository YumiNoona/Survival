class_name MusicConfig

enum Keys {
	IslandAmbience,
	MainMenuSong,
	CreditsMusic
}

const FILE_PATHS := {
	Keys.IslandAmbience : "res://Assets/Audio/Music/IslandAmbience.ogg",
	Keys.MainMenuSong : "res://Assets/Audio/Music/MainTheme.ogg",
	Keys.CreditsMusic : "res://Assets/Audio/Music/AutumnEnding.ogg"
}



static func get_audio_stream(key:Keys) -> AudioStream:
	return load(FILE_PATHS.get(key))
