class_name ItemConfig

enum Keys {
	Stick,
	Stone,
	Plant,
	Mushroom
}

const ITEM_RESOURCE_PATHS := {
	Keys.Stick : "res://Resources/ItemResources/ItemStick.tres",
	Keys.Stone : "res://Resources/ItemResources/ItemStone.tres",
	Keys.Plant : "res://Resources/ItemResources/ItemPlant.tres",
	Keys.Mushroom : "res://Resources/ItemResources/ItemMushroom.tres"
}

static func get_item_resource(key : Keys) -> ItemResource:
	return load(ITEM_RESOURCE_PATHS.get(key))
