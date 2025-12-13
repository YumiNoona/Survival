extends TextureRect
class_name InventorySlot

@onready var Icon: TextureRect = $MarginContainer/Icon

var item_key : Variant = null


func set_item_key(_item_key) -> void:
	item_key = _item_key
	update_icon()


func update_icon() -> void:
	if item_key == null:
		Icon.texture = null
		return

	Icon.texture = ItemConfig.get_item_resource(item_key).icon


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_key != null:
		var drag_preview := TextureRect.new()
		drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		drag_preview.texture = Icon.texture
		drag_preview.size = Vector2(80, 80)
		drag_preview.modulate.a = 0.7
		set_drag_preview(drag_preview)
		#EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
		return self
	
	return null

func _can_drop_data(_at_position: Vector2, slot: Variant) -> bool:
	if item_key != null:
		if slot is HotbarSlot:
			return ItemConfig.get_item_resource(item_key).is_equippable
		
		if slot is StartingCookingSlot:
			return ItemConfig.get_item_resource(item_key).cooking_recipe_resource != null
		
		if slot is FinalCookingSlot:
			return false
	
	return slot is InventorySlot


func _drop_data(_at_position: Vector2, old_slot: Variant) -> void:
	if old_slot is StartingCookingSlot:
		var temp_own_key = item_key
		EventSystem.INV_add_item_by_index.emit(old_slot.item_key, get_index(), self is HotbarSlot)
		old_slot.set_item_key(temp_own_key)
		old_slot.starting_ingredient_disabled.emit()
	
	elif old_slot is FinalCookingSlot:
		EventSystem.INV_add_item_by_index.emit(old_slot.item_key, get_index(), self is HotbarSlot)
		old_slot.set_item_key(null)
		old_slot.cooked_food_taken.emit()
	
	else:
			EventSystem.INV_switch_to_item_indexes.emit(
			old_slot.get_index(),
			old_slot is HotbarSlot,
			get_index(),
			self is HotbarSlot
			)
	
	#EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.UIClick)
