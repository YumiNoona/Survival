extends Node


@onready var notification_container: VBoxContainer

var notification_scene: PackedScene = preload("res://Scenes/UI/SkillUnlockNotification.tscn")
var active_notifications: Array[SkillUnlockNotification] = []

func _enter_tree() -> void:
	EventSystem.SKL_skill_unlocked.connect(_on_skill_unlocked)
	EventSystem.LEV_level_up.connect(_on_level_up)

func _ready() -> void:
	await get_tree().process_frame
	_setup_notification_container()

func _setup_notification_container() -> void:
	var ui_layer = get_parent()
	if not ui_layer or not ui_layer is CanvasLayer:
		push_warning("NotificationManager: Could not find UI CanvasLayer parent")
		return


	var existing = ui_layer.get_node_or_null("NotificationContainer")
	if existing:
		notification_container = existing as VBoxContainer
		return

	notification_container = VBoxContainer.new()
	notification_container.name = "NotificationContainer"
	notification_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	notification_container.offset_left = 20.0
	notification_container.offset_top = 20.0
	notification_container.offset_right = 20.0
	notification_container.offset_bottom = 20.0
	notification_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	notification_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	notification_container.add_theme_constant_override("separation", 10)
	ui_layer.add_child(notification_container)

func _on_skill_unlocked(skill_key: String) -> void:
	if has_node("/root/BulletinController"):
		var bulletin_controller = get_node("/root/BulletinController")
		if bulletin_controller.bulletins.has(BulletinConfig.Keys.SkillTree):
			return 
	
	show_skill_unlock_notification(skill_key)

func show_skill_unlock_notification(skill_key: String) -> void:
	if not notification_container:
		_setup_notification_container()
	
	if not notification_container:
		push_warning("NotificationManager: No notification container available")
		return
	
	if not notification_scene:
		push_warning("NotificationManager: Notification scene not loaded")
		return
	
	var notif_instance = notification_scene.instantiate() as SkillUnlockNotification
	if not notif_instance:
		push_warning("NotificationManager: Failed to instantiate notification")
		return
	
	notif_instance.setup_notification(skill_key)
	notification_container.add_child(notif_instance)
	active_notifications.append(notif_instance)
	notif_instance.tree_exiting.connect(_on_notification_removed.bind(notif_instance))
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.Craft)

func _on_notification_removed(notif_instance: SkillUnlockNotification) -> void:
	active_notifications.erase(notif_instance)

func _on_level_up(new_level: int, _old_level: int) -> void:
	show_level_up_notification(new_level)

func show_level_up_notification(level: int) -> void:
	if not notification_container:
		_setup_notification_container()
	
	if not notification_container:
		push_warning("NotificationManager: No notification container available")
		return
	
	var level_up_scene = load("res://Scenes/UI/LevelUpNotification.tscn")
	if not level_up_scene:
		push_warning("NotificationManager: Level up notification scene not found")
		return
	
	var notif_instance = level_up_scene.instantiate() as LevelUpNotification
	if not notif_instance:
		push_warning("NotificationManager: Failed to instantiate level up notification")
		return
	
	notif_instance.setup_notification(level)
	notification_container.add_child(notif_instance)
	EventSystem.SFX_play_sfx.emit(SFXConfig.Keys.Craft)
