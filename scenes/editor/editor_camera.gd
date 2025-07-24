extends Camera2D


export var speed: float = 12.0
export var zoom_level: float = 1.0
export var smoothing: float = 12.5

var editor: Editor = get_owner()

var last_pos: Vector2
var sim_pos: Vector2


signal zoom_changed(zoom_level)

var speedup_held: bool
var is_moving: bool

func _ready():
	position = Vector2(288, 840)

func _unhandled_input(event):
	var zoom_amount = 0.25
	if Input.is_action_pressed("8_pixel_lock"):
		zoom_amount = 0.05
	
	if event.is_action_pressed("zoom_out"):
		add_zoom_level(zoom_amount)
	elif event.is_action_pressed("zoom_in"):
		add_zoom_level(-zoom_amount)
	
	if event.is_action_pressed("speed_up_camera"):
		speedup_held = true
	if event.is_action_released("speed_up_camera"):
		speedup_held = false


func _physics_process(delta):
	zoom = zoom.linear_interpolate(Vector2(zoom_level, zoom_level), delta * 30.0)
	camera_movement(delta)


func load_in(_level_data: LevelData, level_area: LevelArea):
	for object in level_area.objects:
		if is_instance_valid(object) and object is ObjectData:
			if object.type_id == 0:
				position = object.properties[0] # properties[0] is always position, at least for spawners
	
	update_limits(level_area)


func camera_movement(delta: float):
	var editor_ui: Control = get_node("%EditorUI")
	
	var move_speed = speed * 2 if speedup_held else speed
	var direction := Input.get_vector("editor_left", "editor_right", "editor_up", "editor_down")
	
	if is_instance_valid(editor_ui.get_focus_owner()):
		move_speed = 0
	
	
	last_pos = position
	sim_pos += direction * move_speed * 60 * delta
	sim_pos = resolve_limit_collisions(sim_pos)
	
	position = lerp(position, sim_pos, 12.5 * delta)
	position = resolve_limit_collisions(position)
	


func is_moving() -> bool:
	return not position.is_equal_approx(last_pos)


func update_limits(level_area: LevelArea):
	var area_bounds = level_area.settings.bounds.grow(3)
	
	limit_left = int(area_bounds.position.x * 32)
	limit_top = int(area_bounds.position.y * 32 * zoom.x) #needs to include the toolbar
	
	limit_right = int(area_bounds.end.x * 32)
	limit_bottom = int(area_bounds.end.y * 32)
	
	sim_pos = resolve_limit_collisions(sim_pos)
	position = resolve_limit_collisions(position)


func resolve_limit_collisions(pos: Vector2) -> Vector2:
	# If you were curious, this stops the camera node's position value from
	# exceeding the level bounds. If you don't do this, the camera will continue
	# to move past the limits while the viewport won't.
	
	var camera_left = pos.x - ((get_viewport_rect().size.x / 2) * zoom.x)
	var camera_right = pos.x + ((get_viewport_rect().size.x / 2) * zoom.x)
	var camera_up = pos.y - ((get_viewport_rect().size.y / 2) * zoom.y)
	var camera_down = pos.y + ((get_viewport_rect().size.y / 2) * zoom.y)
	
	if camera_left < limit_left:
		pos.x = limit_left + ((get_viewport_rect().size.x / 2) * zoom.x)
	if camera_right > limit_right:
		pos.x = limit_right - ((get_viewport_rect().size.x / 2) * zoom.x)
	if camera_up < limit_top:
		pos.y = limit_top + ((get_viewport_rect().size.y / 2) * zoom.y)
	if camera_down > limit_bottom:
		pos.y = limit_bottom - ((get_viewport_rect().size.y / 2) * zoom.y)
	
	return pos


# Functions to avoid copy pasted code
func cap_zoom_level(zoom : float) -> float:
	# Reduce the zoom level if the screen wouldn't fit within the level
	# NOTE: all tile counts are +6 since there are 3 tiles OOB in both directions for both axis
	var viewport_size := Vector2(
		ProjectSettings.get_setting("display/window/size/width"), 
		ProjectSettings.get_setting("display/window/size/height")
	)
	# This accounts for the toolbar cutting off the top 70 pixels of the screen,
	# I'd prefer to not hardcode this but frankly it's not worth the time to 
	# figure out getting the height of the toolbar.
	var toolbar_size : float = 0
	var level_size : Vector2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds.size

	while (
		viewport_size.x * zoom > (level_size.x + 6) * Editor.TILE_SIZE.x or 
		(viewport_size.y - 70) * zoom > (level_size.y + 6) * Editor.TILE_SIZE.y
	):
		zoom = zoom - .05
	
	return zoom


func set_zoom_level(level : float) -> void:
	# Zoom level limits
	if level < 0.25: level = 0.25 # lower limit on zoom
	
#	if level > 4.01: # 4 flat wouldn't work and I don't know why
#		$Grid.visible = false
#	else:
#		$Grid.visible = true
	
	zoom_level = cap_zoom_level(level) # makes sure the zoom isn't too large
	Singleton.EditorSavedSettings.zoom_level = zoom_level
	emit_signal("zoom_changed", zoom_level)


func add_zoom_level(level : float) -> void:
	set_zoom_level(zoom_level + level)


func _on_ResetZoom_button_down():
	set_zoom_level(1.0)
