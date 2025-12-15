class_name BulletinConfig

enum Keys {
	InteractionPrompt,
	CraftingMenu,
	CookingMenu,
	PauseMenu,
	SettingsMenu,
}

const BULLETIN_PATHS := {
	Keys.InteractionPrompt : "res://Scenes/UI/InteractionPrompt.tscn",
	Keys.CraftingMenu : "res://Scenes/UI/CraftingMenu.tscn",
	Keys.CookingMenu : "res://Scenes/UI/CookingMenu.tscn",
	Keys.PauseMenu : "res://Scenes/UI/PauseMenu.tscn",
	Keys.SettingsMenu : "res://Scenes/UI/SettingsMenu.tscn",
}

static func get_bulletin(key : Keys) -> Bulletin:
	return load(BULLETIN_PATHS.get(key)).instantiate()
