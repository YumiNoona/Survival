class_name ItemConfig

enum Keys {
	#PickAbles
	Stick,
	Stone,
	Plant,
	Mushroom,
	Fruit,
	Log,
	Coal,
	Flintstone,
	RawMeat,
	CookedMeat,
	
	#Craftables
	Axe,
	Pickaxe,
	Campfire,
	Multitool,
	Rope,
	Tinderbox,
	Torch,
	Tent,
	Raft,
}

const CRAFTABLE_ITEM_KEYS : Array[Keys] = [
	Keys.Axe,
	#Keys.Pickaxe,
	#Keys.Campfire,
	#Keys.Multitool,
	Keys.Rope,
	#Keys.Tinderbox,
	#Keys.Torch,
	#Keys.Tent,
	#Keys.Raft
]

const ITEM_RESOURCE_PATHS := {
	#PickAble
	Keys.Stick : "res://Resources/ItemResources/ItemStick.tres",
	Keys.Stone : "res://Resources/ItemResources/ItemStone.tres",
	Keys.Plant : "res://Resources/ItemResources/ItemPlant.tres",
	Keys.Fruit : "res://Resources/ItemResources/ItemFruit.tres",
	Keys.Log : "res://Resources/ItemResources/ItemLog.tres",
	Keys.Coal : "res://Resources/ItemResources/ItemCoal.tres",
	Keys.Flintstone : "res://Resources/ItemResources/ItemFlintStone.tres",
	Keys.RawMeat : "res://Resources/ItemResources/ItemRawMeat.tres",
	Keys.CookedMeat : "res://Resources/ItemResources/ItemCookedMeat.tres",
	Keys.Mushroom : "res://Resources/ItemResources/ItemMushroom.tres",
	
	#CraftAble
	Keys.Axe : "res://Resources/Weapons/AxeWeapon.tres",
	Keys.Pickaxe : "res://Resources/ItemResources/CraftPickAxe.tres",
	Keys.Campfire : "res://Resources/ItemResources/CraftCampFire.tres",
	Keys.Multitool : "res://Resources/ItemResources/CraftMultitool.tres",
	Keys.Rope : "res://Resources/ItemResources/CraftRope.tres",
	Keys.Tinderbox : "res://Resources/ItemResources/CraftTinderBox.tres",
	Keys.Torch : "res://Resources/ItemResources/CraftTorch.tres",
	Keys.Tent : "res://Resources/ItemResources/CraftTent.tres",
	Keys.Raft : "res://Resources/ItemResources/CraftRaft.tres"
}

const CRAFTING_RESOURCE_PATHS := {
	
	Keys.Axe : "res://Resources/Craftable/Axe.tres",
	Keys.Rope : "res://Resources/Craftable/Rope.tres"
}


static func get_item_resource(key : Keys) -> ItemResource:
	return load(ITEM_RESOURCE_PATHS.get(key))

static func get_crafting_resource(key : Keys) -> CraftingResource:
	return load(CRAFTING_RESOURCE_PATHS.get(key))

const EQUIPPABLE_ITEM_PATHS := {
	Keys.Axe : "res://Scenes/Interactive/EquippAble/EquippableAxe.tscn"
}

static func get_equippable_item(key : Keys) -> PackedScene:
	return load(EQUIPPABLE_ITEM_PATHS.get(key))
