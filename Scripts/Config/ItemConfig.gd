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
	Keys.Pickaxe,
	Keys.Campfire,
	Keys.Multitool,
	Keys.Rope,
	Keys.Tinderbox,
	Keys.Torch,
	Keys.Tent,
	Keys.Raft
]

const ITEM_RESOURCE_PATHS := {
	#NonEqquippAble
	Keys.Stick : "res://Resources/ItemResources/ItemStick.tres",
	Keys.Stone : "res://Resources/ItemResources/ItemStone.tres",
	Keys.Plant : "res://Resources/ItemResources/ItemPlant.tres",
	Keys.Flintstone : "res://Resources/ItemResources/ItemFlintStone.tres",
	Keys.Log : "res://Resources/ItemResources/ItemLog.tres",
	Keys.Coal : "res://Resources/ItemResources/ItemCoal.tres",
	Keys.RawMeat : "res://Resources/ItemResources/ItemRawMeat.tres",
	Keys.Multitool : "res://Resources/ItemResources/ItemMultitool.tres",
	Keys.Tinderbox : "res://Resources/ItemResources/ItemTinderBox.tres",
	Keys.Rope : "res://Resources/ItemResources/ItemRope.tres",
	
	#EqquippAble
	Keys.Axe : "res://Resources/Weapons/WeaponAxe.tres",
	Keys.Pickaxe : "res://Resources/Weapons/WeaponPickAxe.tres",
	Keys.Torch : "res://Resources/Weapons/WeaponTorch.tres",
	Keys.Fruit : "res://Resources/Cosumables/Cosumable_Fruit.tres",
	Keys.Mushroom : "res://Resources/Cosumables/Cosumable_Mushroom.tres",
	Keys.CookedMeat :"res://Resources/Cosumables/Cosumable_CookedMeat.tres" ,
	Keys.Tent : "res://Resources/ItemResources/ItemTent.tres",
	Keys.Campfire : "res://Resources/ItemResources/ItemCampFire.tres",
	Keys.Raft : "res://Resources/ItemResources/ItemRaft.tres"
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
	Keys.Axe : "res://Scenes/Interactive/EquippAble/Weapon/EquippableAxe.tscn",
	Keys.Pickaxe : "res://Scenes/Interactive/EquippAble/Weapon/EquippablePickAxe.tscn",
	Keys.Mushroom : "res://Scenes/Interactive/EquippAble/ConsumAble/EquippableMushroom.tscn",
	Keys.Tent : "res://Scenes/Interactive/EquippAble/ConstructAble/EquippableConstructablesTent.tscn",
	Keys.Campfire : "res://Scenes/Interactive/EquippAble/ConstructAble/EquippableConstructablesCampfire.tscn",
	Keys.Raft : "res://Scenes/Interactive/EquippAble/ConstructAble/EquippableConstructablesRaft.tscn",
	Keys.CookedMeat : "res://Scenes/Interactive/EquippAble/ConsumAble/EquippableCookedMeat.tscn",
	Keys.Fruit : "res://Scenes/Interactive/EquippAble/ConsumAble/EquippableFruit.tscn",
	Keys.Torch : "res://Scenes/Interactive/EquippAble/Weapon/EquippableTorch.tscn",
}


const PICKUPPABLE_ITEM_PATHS := {
	Keys.Log : "res://Scenes/Interactive/Rigid/RigidPickAbleLog.tscn",
	Keys.Coal : "res://Scenes/Interactive/Rigid/Rigid_PickAbleCoal.tscn",
	Keys.RawMeat : "res://Scenes/Interactive/Rigid/Rigid_PickAbleRawMeat.tscn",
	Keys.Flintstone : "res://Scenes/Interactive/Rigid/Rigid_PickAbleFlintstone.tscn"
}

const CONSTRUCTTABLE_SCENE := {
	Keys.Tent : "res://Scenes/Interactive/Constructables/ConstructableTent.tscn", 
	Keys.Raft : "res://Scenes/Interactive/Constructables/ConstructableRaft.tscn", 
	Keys.Campfire : "res://Scenes/Interactive/Constructables/ConstructableCampfire.tscn",
}

const ITEMS_BY_ID := {
	# Pickables
	Keys.Stick : "res://Resources/ItemResources/ItemStick.tres",
	Keys.Stone : "res://Resources/ItemResources/ItemStone.tres",
	Keys.Plant : "res://Resources/ItemResources/ItemPlant.tres",
	Keys.Mushroom : "res://Resources/Cosumables/Cosumable_Mushroom.tres",
	Keys.Fruit : "res://Resources/Cosumables/Cosumable_Fruit.tres",
	Keys.Log : "res://Resources/ItemResources/ItemLog.tres",
	Keys.Coal : "res://Resources/ItemResources/ItemCoal.tres",
	Keys.Flintstone : "res://Resources/ItemResources/ItemFlintStone.tres",
	Keys.RawMeat : "res://Resources/ItemResources/ItemRawMeat.tres",
	Keys.CookedMeat : "res://Resources/Cosumables/Cosumable_CookedMeat.tres",
	
	# Craftables/Equippables
	Keys.Axe : "res://Resources/Weapons/WeaponAxe.tres",
	Keys.Pickaxe : "res://Resources/Weapons/WeaponPickAxe.tres",
	Keys.Campfire : "res://Resources/ItemResources/ItemCampFire.tres",
	Keys.Multitool : "res://Resources/ItemResources/ItemMultitool.tres",
	Keys.Rope : "res://Resources/ItemResources/ItemRope.tres",
	Keys.Tinderbox : "res://Resources/ItemResources/ItemTinderBox.tres",
	Keys.Torch : "res://Resources/Weapons/WeaponTorch.tres",
	Keys.Tent : "res://Resources/ItemResources/ItemTent.tres",
	Keys.Raft : "res://Resources/ItemResources/ItemRaft.tres",
}


static func get_item_resource(key : Keys) -> ItemResource:
	return load(ITEM_RESOURCE_PATHS.get(key))


static func get_item_resource_by_id(id: int) -> ItemResource:
	if ITEMS_BY_ID.has(id):
		return load(ITEMS_BY_ID.get(id))
	return null


static func get_crafting_resource(key : Keys) -> CraftingResource:
	return load(CRAFTING_RESOURCE_PATHS.get(key))


static func get_equippable_item(key : Keys) -> PackedScene:
	return load(EQUIPPABLE_ITEM_PATHS.get(key))


static func get_pickuppable_item(key : Keys) -> PackedScene:
	return load(PICKUPPABLE_ITEM_PATHS.get(key))


static func get_constructable_scene(key : Keys) -> PackedScene:
	return load(CONSTRUCTTABLE_SCENE.get(key))
