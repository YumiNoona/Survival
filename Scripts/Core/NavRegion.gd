extends NavigationRegion3D

var bake_timer: Timer
var baking_in_progress := false

func _enter_tree() -> void:
	EventSystem.GAM_update_navmesh.connect(_on_update_navmesh_requested)
	
	bake_timer = Timer.new()
	bake_timer.wait_time = 0.1
	bake_timer.one_shot = true
	bake_timer.timeout.connect(_perform_bake)
	add_child(bake_timer)

func _on_update_navmesh_requested() -> void:
	if baking_in_progress:
		return
	
	if bake_timer.is_stopped():
		bake_timer.start()
	else:
		bake_timer.wait_time = 0.1
		bake_timer.start()

func _perform_bake() -> void:
	if not is_inside_tree():
		return
	
	baking_in_progress = true
	await get_tree().process_frame
	bake_navigation_mesh()
	await get_tree().process_frame
	baking_in_progress = false
