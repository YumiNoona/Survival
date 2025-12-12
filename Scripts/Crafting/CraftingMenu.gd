extends PlayerMenuBase

@onready var crafting_button_container: GridContainer = %CraftingButtonContainer

@export var crafting_button_scene : PackedScene

func _ready() -> void:
	for craftable_item_key in ItemConfig.CRAFTABLE_ITEM_KEYS:
		var crafting_button := crafting_button_scene.instantiate()
		crafting_button_container.add_child(crafting_button)
		crafting_button.set_item_key(craftable_item_key)
		crafting_button.button.mouse_entered.connect(show_crafting_info.bind(crafting_button.item_key))
		crafting_button.button.mouse_exited.connect(hide_crafting_info)
		crafting_button.button.pressed.connect(crafting_button_pressed.bind	(crafting_button.item_key))
	
	super._ready()
		
func show_crafting_info(item_key : ItemConfig.Keys) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or item_key == null:
		return

	var item_resource := ItemConfig.get_item_resource(item_key)

	item_description.text = item_resource.display_name + "\n" + item_resource.description
	item_extra_info.text = "Requirements:"

	var blueprint := ItemConfig.get_crafting_resource(item_key)

	if blueprint.needs_multitool:
		item_extra_info.text += "\nMultiTool"
		
	if blueprint.needs_tinderbox:
		item_extra_info.text += "\nTinderBox"

	for cost_resource in blueprint.costs:
		item_extra_info.text += "\n%s: %d" % [
			ItemConfig.get_item_resource(cost_resource.item_key).display_name,
			cost_resource.amount
		]


func hide_crafting_info() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	item_description.text = ""
	item_extra_info.text = ""

func update_inventory(inventory : Array) -> void:
	super.update_inventory(inventory)

	for crafting_button in crafting_button_container.get_children():
		var costs := ItemConfig.get_crafting_resource(crafting_button.item_key).costs
		var disable_button := false

		for cost_data in costs:
			if inventory.count(cost_data.item_key) < cost_data.amount:
				disable_button = true
				break

		crafting_button.button.disabled = disable_button


func crafting_button_pressed(item_key : ItemConfig.Keys) -> void:
	EventSystem.INV_delete_crafting_item.emit(ItemConfig.get_crafting_resource(item_key).costs)
	EventSystem.INV_add_item.emit(item_key)
