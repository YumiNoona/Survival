extends HBoxContainer

var signals_connected := false

func _enter_tree() -> void:
	if signals_connected:
		return
	
	EventSystem.INV_hotbar_updated.connect(update_hotbar)
	EventSystem.EQU_active_hotbar_slot_updated.connect(active_slot_updated)
	EventSystem.EQU_unequip_item.connect(active_slot_updated.bind(-1))
	signals_connected = true

func update_hotbar(hotbar: Array) -> void:
	for slot in get_children():
		slot.set_item_key(hotbar[slot.get_index()])

func active_slot_updated(idx: int) -> void:
	for slot in get_children():
		slot.set_highlighted(slot.get_index() == idx)
