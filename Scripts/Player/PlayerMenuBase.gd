extends Bulletin
class_name PlayerMenuBase

@onready var inventory_container: GridContainer = %InventoryContainer
@onready var item_description: Label = %ItemDescription
@onready var item_extra_info: Label = %ItemExtraInfo
@onready var filter_button: OptionButton = %FilterButton

enum FilterType {
	ALL,
	WEAPONS,
	CONSUMABLES,
	ITEMS
}


@export var inventory_slot_scene: PackedScene

var _ready_called := false
var slot_signals_connected := false

func _enter_tree() -> void:
	EventSystem.INV_inventory_updated.connect(_on_inventory_updated)
	EventSystem.INV_inventory_slots_added.connect(_on_inventory_slots_added)

func _on_inventory_updated(inventory: Array) -> void:
	call_deferred("update_inventory", inventory)

func _ready() -> void:
	if _ready_called:
		return
	_ready_called = true
	
	EventSystem.PLA_freeze_player.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventSystem.INV_ask_update_inventory.emit()
	

	if filter_button:
		filter_button.add_item("All")
		filter_button.add_item("Weapons")
		filter_button.add_item("Consumables")
		filter_button.add_item("Items")
		filter_button.selected = FilterType.ALL
		filter_button.item_selected.connect(_on_filter_selected)
	

	if not slot_signals_connected:
		for i in range(inventory_container.get_child_count()):
			var slot := inventory_container.get_child(i)
			var bound_func = show_item_info.bind(i)
			if not slot.mouse_entered.is_connected(bound_func):
				slot.mouse_entered.connect(bound_func)
			if not slot.mouse_exited.is_connected(hide_item_info):
				slot.mouse_exited.connect(hide_item_info)
		slot_signals_connected = true

	for hotbar_slot in get_tree().get_nodes_in_group("HotBarSlots"):
		hotbar_slot.mouse_entered.connect(show_item_info.bind(hotbar_slot))
		hotbar_slot.mouse_exited.connect(hide_item_info)
		
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
	
	%ScrapSlot.item_scrapped.connect(hide_item_info)
	apply_filter()

func show_item_info(slot_identifier) -> void:
	var slot : InventorySlot

	if typeof(slot_identifier) == TYPE_INT:
		slot = inventory_container.get_child(slot_identifier)
	else:
		slot = slot_identifier

	var item_key : Variant = slot.item_key

	if item_key == null:
		item_description.text = ""
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and item_key == null:
		return
	
	var item_resource := ItemConfig.get_item_resource(item_key)
	
	item_description.text = item_resource.display_name + "\n" + item_resource.description


func hide_item_info() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	item_description.text = ""

func update_inventory(inventory : Array) -> void:
	if not visible or not is_inside_tree():
		return

	if not inventory_container or not is_instance_valid(inventory_container):
		return
		
	ensure_slots_exist(inventory.size())

	for i in inventory.size():
		if i < inventory_container.get_child_count():
			inventory_container.get_child(i).set_item_key(inventory[i])
	apply_filter()

func ensure_slots_exist(required_count: int) -> void:
	if not inventory_container or not is_instance_valid(inventory_container):
		return
	
	var current_slot_count = inventory_container.get_child_count()
	
	if current_slot_count < required_count:
		if not inventory_slot_scene:
			if current_slot_count > 0:
				var existing_slot = inventory_container.get_child(0)
				if existing_slot and is_instance_valid(existing_slot):
					inventory_slot_scene = load(existing_slot.scene_file_path) as PackedScene
			if not inventory_slot_scene:
				push_error("No inventory slot scene available!")
				return


		for i in range(required_count - current_slot_count):
			var new_slot = inventory_slot_scene.instantiate()
			if new_slot and inventory_container:
				inventory_container.add_child(new_slot)
				var slot_index = current_slot_count + i
				if new_slot.has_signal("mouse_entered"):
					new_slot.mouse_entered.connect(show_item_info.bind(slot_index))
				if new_slot.has_signal("mouse_exited"):
					new_slot.mouse_exited.connect(hide_item_info)

func _on_inventory_slots_added(_amount: int) -> void:
	pass


func _on_filter_selected(_index: int) -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
	apply_filter()


func apply_filter() -> void:
	if not filter_button:
		for i in range(inventory_container.get_child_count()):
			var slot: InventorySlot = inventory_container.get_child(i)
			slot.visible = true
		return
	
	var filter_type = filter_button.selected
	

	if filter_type == FilterType.ALL:
		for i in range(inventory_container.get_child_count()):
			var slot: InventorySlot = inventory_container.get_child(i)
			slot.visible = true
		return
	

	for i in range(inventory_container.get_child_count()):
		var slot: InventorySlot = inventory_container.get_child(i)
		var should_show = should_show_slot(slot, filter_type)
		slot.visible = should_show


func should_show_slot(slot: InventorySlot, filter_type: int) -> bool:
	if slot.item_key == null:
		return false
	
	var item_resource = ItemConfig.get_item_resource(slot.item_key)
	
	match filter_type:
		FilterType.WEAPONS:
			return item_resource is WeaponResource
		FilterType.CONSUMABLES:
			return item_resource is ConsumableResource
		FilterType.ITEMS:
			return not (item_resource is WeaponResource or item_resource is ConsumableResource)
	
	return true


func close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.CraftingMenu)
	EventSystem.PLA_unfreeze_player.emit()
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
