class_name BulletinConfig

enum Keys {
	InteractionPrompt,
	CraftingMenu
}

const BULLETIN_PATHS := {
	Keys.InteractionPrompt : "res://Scenes/UI/InteractionPrompt.tscn",
	Keys.CraftingMenu : "res://Scenes/UI/CraftingMenu.tscn"
}

static func get_bulletin(key : Keys) -> Bulletin:
	return load(BULLETIN_PATHS.get(key)).instantiate()
