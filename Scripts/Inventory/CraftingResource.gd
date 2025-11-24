extends Resource
class_name CraftingResource

@export var item_item_key := ItemConfig.Keys.Axe
@export var costs : Array[CraftingCost] = []
@export var needs_multitool := false
@export var needs_tinderbox := false
