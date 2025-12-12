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
	Keys.Flintstone : "res://Resources/ItemResources/ItemFlintStone.tres",
	Keys.Log : "res://Resources/ItemResources/ItemLog.tres",
	Keys.Coal : "res://Resources/ItemResources/ItemCoal.tres",
	
	#Cooking
	Keys.RawMeat : "res://Resources/ItemResources/ItemRawMeat.tres",
	
	#Consumables
	Keys.Fruit : "res://Resources/Cosumables/Cosumable_Fruit.tres",
	Keys.Mushroom : "res://Resources/Cosumables/Cosumable_Mushroom.tres",
	Keys.CookedMeat : "res://Resources/ItemResources/ItemCookedMeat.tres",
	
	#CraftAble
	Keys.Axe : "res://Resources/Weapons/WeaponAxe.tres",
	Keys.Pickaxe : "res://Resources/Weapons/WeaponPickAxe.tres",
	Keys.Rope : "res://Resources/ItemResources/CraftRope.tres",
	Keys.Multitool : "res://Resources/ItemResources/CraftMultitool.tres",
	Keys.Tinderbox : "res://Resources/ItemResources/CraftTinderBox.tres",
	Keys.Torch : "res://Resources/ItemResources/CraftTorch.tres",
	Keys.Tent : "res://Resources/ItemResources/CraftTent.tres",
	Keys.Campfire : "res://Resources/ItemResources/CraftCampFire.tres",
	Keys.Raft : "res://Resources/ItemResources/CraftRaft.tres"
}

const CRAFTING_RESOURCE_PATHS := {
	
	Keys.Axe : "res://Resources/Craftable/Axe.tres",
	Keys.Rope : "res://Resources/Craftable/Rope.tres",
	Keys.Pickaxe : "res://Resources/Craftable/PickAxe.tres",
	Keys.Campfire : "res://Resources/Craftable/Campfire.tres",
	Keys.Multitool : "res://Resources/Craftable/MultiTool.tres",
	Keys.Raft : "res://Resources/Craftable/Raft.tres",
	Keys.Tent : "res://Resources/Craftable/Tent.tres",
	Keys.Tinderbox : "res://Resources/Craftable/TinderBox.tres",
	Keys.Torch : "res://Resources/Craftable/Torch.tres"
}

const EQUIPPABLE_ITEM_PATHS := {
	Keys.Axe : "res://Scenes/Interactive/EquippAble/EquippableAxe.tscn",
	Keys.Mushroom : "res://Scenes/Interactive/EquippAble/EquippableMushroom.tscn",
	Keys.Pickaxe : "res://Scenes/Interactive/EquippAble/EquippablePickAxe.tscn"
}

const PICKUPPABLE_ITEM_PATHS := {
	Keys.Log : "res://Scenes/Interactive/Rigid/RigidPickAbleLog.tscn",
	Keys.Coal : "res://Scenes/Interactive/Rigid/Rigid_PickAbleCoal.tscn",
	Keys.RawMeat : "res://Scenes/Interactive/Rigid/Rigid_PickAbleRawMeat.tscn",
	Keys.Flintstone : "res://Scenes/Interactive/Rigid/Rigid_PickAbleFlintstone.tscn"
}


static func get_item_resource(key : Keys) -> ItemResource:
	return load(ITEM_RESOURCE_PATHS.get(key))

static func get_crafting_resource(key : Keys) -> CraftingResource:
	return load(CRAFTING_RESOURCE_PATHS.get(key))


static func get_equippable_item(key : Keys) -> PackedScene:
	return load(EQUIPPABLE_ITEM_PATHS.get(key))


static func get_pickuppable_item(key : Keys) -> PackedScene:
	return load(PICKUPPABLE_ITEM_PATHS.get(key))
