extends Bulletin
class_name PlayerMenuBase

@onready var inventory_container: GridContainer = %InventoryContainer
@onready var item_description: Label = %ItemDescription
@onready var item_extra_info: Label = %ItemExtraInfo


func _enter_tree() -> void:
	EventSystem.INV_inventory_updated.connect(update_inventory)

func _ready() -> void:
	EventSystem.PLA_frezze_player.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventSystem.INV_ask_update_inventory.emit()
	
	for i in range(inventory_container.get_child_count()):
		var slot := inventory_container.get_child(i)
		slot.mouse_entered.connect(show_item_info.bind(i))
		slot.mouse_exited.connect(hide_item_info)

	for hotbar_slot in get_tree().get_nodes_in_group("HotBarSlots"):
		hotbar_slot.mouse_entered.connect(show_item_info.bind(hotbar_slot))
		hotbar_slot.mouse_exited.connect(hide_item_info)


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

	
func close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.BUL_destroy_bulletin.emit(BulletinConfig.Keys.CraftingMenu)
	EventSystem.PLA_unfrezze_player.emit()

func update_inventory(inventory : Array) -> void:
	for i in inventory.size():
		inventory_container.get_child(i).set_item_key(inventory[i])
