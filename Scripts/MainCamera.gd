extends Camera3D

@onready var equip_able_item_camera: Camera3D = %EquipAbleItemCamera

func _process(_delta: float) -> void:
	equip_able_item_camera.global_transform = global_transform
