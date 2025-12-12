extends TextureRect

@onready var CraftIcon: TextureRect = $MarginContainer/Icon
@onready var button: Button = $Button

var item_key

func set_item_key(_item_key) -> void:
	item_key = _item_key
	CraftIcon.texture = ItemConfig.get_item_resource(item_key).icon
