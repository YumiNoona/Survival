class_name ItemConfig

enum Keys {
	Stick,
	Stone,
	Plant,
	Mushroom
}

const ITEM_RESOURCE_PATHS := {
	Keys.Stick : "res://Resources/ItemResources/ItemStick.tres"
}

func get_item_resource(key : Keys) -> ItemResource:
	return load(ITEM_RESOURCE_PATHS.get(key))
