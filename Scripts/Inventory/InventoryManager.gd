extends Node

const INVENTORY_SIZE = 28
const HOTBAR_SIZE = 9

var inventory : Array = []
var hotbar : Array = []
var current_inventory_size: int = INVENTORY_SIZE

func _enter_tree() -> void:
	EventSystem.INV_try_to_pickup_item.connect(try_to_pickup_item)
	EventSystem.INV_ask_update_inventory.connect(send_inventory)
	EventSystem.INV_switch_to_item_indexes.connect(switch_to_item_indexes)
	EventSystem.INV_add_item.connect(add_item)
	EventSystem.INV_delete_crafting_item.connect(delete_crafting_item)
	EventSystem.INV_delete_item_by_index.connect(delete_item_by_index)
	EventSystem.INV_add_item_by_index.connect(add_item_by_index)
	EventSystem.INV_add_inventory_slots.connect(_on_add_inventory_slots)
	

func _ready() -> void:
	inventory.resize(INVENTORY_SIZE)
	hotbar.resize(HOTBAR_SIZE)
	current_inventory_size = INVENTORY_SIZE


func send_inventory() -> void:
	EventSystem.INV_inventory_updated.emit(inventory)

func send_hotbar() -> void:
	EventSystem.INV_hotbar_updated.emit(hotbar)

func try_to_pickup_item(item_key : ItemConfig.Keys, destroy_pickuppable : Callable) -> void:
	if not get_free_slots():
		return

	add_item(item_key)
	destroy_pickuppable.call()


func get_free_slots() -> int:
	return inventory.count(null)

func add_item(item_key : ItemConfig.Keys) -> void:
	for i in inventory.size():
		if inventory[i] == null:
			inventory[i] = item_key
			break
			
	send_inventory()

func switch_to_item_indexes(idx1 : int, idx1_is_in_hotbar : bool, idx2 : int, idx2_is_in_hotbar : bool) -> void:
	# Bounds checking
	if not idx1_is_in_hotbar and (idx1 < 0 or idx1 >= inventory.size()):
		return
	if idx1_is_in_hotbar and (idx1 < 0 or idx1 >= hotbar.size()):
		return
	if not idx2_is_in_hotbar and (idx2 < 0 or idx2 >= inventory.size()):
		return
	if idx2_is_in_hotbar and (idx2 < 0 or idx2 >= hotbar.size()):
		return
	
	var item1 = inventory[idx1] if not idx1_is_in_hotbar else hotbar[idx1]
	var item2 = inventory[idx2] if not idx2_is_in_hotbar else hotbar[idx2]

	if not idx1_is_in_hotbar:
		inventory[idx1] = item2
	else:
		hotbar[idx1] = item2

	if not idx2_is_in_hotbar:
		inventory[idx2] = item1
	else:
		hotbar[idx2] = item1

	send_inventory()
	send_hotbar()

func delete_crafting_item(costs : Array[CraftingCost]) -> void:
	for cost in costs:
		for _i in range(cost.amount):
			delete_item(cost.item_key)

func delete_item_by_index(index: int, is_in_hotbar: bool) -> void:
	if is_in_hotbar:
		hotbar[index] = null
		send_hotbar()
		
	else:
		inventory[index] = null
		send_inventory()

func add_item_by_index(item_key:ItemConfig.Keys ,index: int, is_in_hotbar: bool) -> void:
	if is_in_hotbar:
		hotbar[index] = item_key
		send_hotbar()
		
	else:
		inventory[index] = item_key
		send_inventory()


func delete_item(item_key : ItemConfig.Keys) -> void:
	if not inventory.has(item_key):
		return

	inventory[inventory.rfind(item_key)] = null
	send_inventory()

func _on_add_inventory_slots(amount: int) -> void:
	current_inventory_size += amount
	inventory.resize(current_inventory_size)
	EventSystem.INV_inventory_slots_added.emit(amount)
	send_inventory()
