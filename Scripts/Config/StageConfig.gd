class_name StageConfig

enum Keys {
	Island,
	MainMenu,
	PauseMenu,
	Credits,
}

const STAGE_PATHS := {
	Keys.Island : "res://Scenes/Core/Island.tscn",
	Keys.MainMenu : "res://Scenes/UI/MainMenu.tscn",
	Keys.PauseMenu : "res://Scenes/UI/PauseMenu.tscn",
	Keys.Credits : "res://Scenes/UI/Credits.tscn",
}

static func get_stage(key : Keys) -> Node:
	return load(STAGE_PATHS.get(key)).instantiate()
