extends Camera2D


export(NodePath) var editor_path
onready var editor = get_node(editor_path)

export var speed: float = 12.0


# tracks whether the actions below are held or not
var actions := {
	"editor_left": false,
	"editor_right": false,
	"editor_up": false,
	"editor_down": false,
}

func _unhandled_input(event):
	for action in actions.keys():
		if event.is_action_pressed(action):
			actions[action] = true
		elif event.is_action_released(action):
			actions[action] = false


func _physics_process(delta):
	var can_move: bool = true
	
	for action in actions.values():
		if action == false:
			can_move = false
			break
	
	if actions.values().has(true):
		camera_movement(delta)


func load_in(_level_data: LevelData, level_area: LevelArea):
	for object in level_area.objects:
		if is_instance_valid(object) and object is ObjectData:
			if object.type_id == 0:
				position = object.properties[0] # properties[0] is always position, at least for spawners
	
	update_limits(level_area)


func camera_movement(delta: float):
	var move_speed = speed * 2 if Input.is_action_pressed("speed_up_camera") else speed
	var direction := Input.get_vector("editor_left", "editor_right", "editor_up", "editor_down")
	
	position += direction*move_speed*60*delta
	
	resolve_limit_collisions()


func update_limits(level_area : LevelArea):
	var area_bounds = level_area.settings.bounds.grow(3)

	limit_left  = int(area_bounds.position.x * 32)
	limit_top   = int(area_bounds.position.y * 32 - 70 * zoom.x) #needs to include the toolbar

	limit_right  = int(area_bounds.end.x * 32)
	limit_bottom = int(area_bounds.end.y * 32)

	resolve_limit_collisions()


func resolve_limit_collisions():
	var camera_left = position.x - ((get_viewport_rect().size.x / 2) * zoom.x)
	var camera_right = position.x + ((get_viewport_rect().size.x / 2) * zoom.x)
	var camera_up = position.y - ((get_viewport_rect().size.y / 2) * zoom.y)
	var camera_down = position.y + ((get_viewport_rect().size.y / 2) * zoom.y)
	
	if camera_left < limit_left:
		position.x = limit_left + ((get_viewport_rect().size.x / 2) * zoom.x)
	if camera_right > limit_right:
		position.x = limit_right - ((get_viewport_rect().size.x / 2) * zoom.x)
	if camera_up < limit_top:
		position.y = limit_top + ((get_viewport_rect().size.y / 2) * zoom.y)
	if camera_down > limit_bottom:
		position.y = limit_bottom - ((get_viewport_rect().size.y / 2) * zoom.y)
