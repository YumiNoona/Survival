extends Interactable
class_name Pickuppable

@export var item_key : ItemConfig.Keys

@onready var parent : Node3D = get_parent()

func start_interaction() -> void:
	EventSystem.INV_try_to_pickup_item.emit(item_key, destroy_self)

func destroy_self() -> void:
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.ItemPickup)
	parent.queue_free()
