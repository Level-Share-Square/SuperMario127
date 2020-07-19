extends Camera2D

export var character : NodePath
var focus_on : Node
var unfocusing := false
var focus_zoom := 1.0

onready var character_node = get_node(character)

var character_vel = Vector2(0, 0)
func _physics_process(delta):
	if focus_on != null:
		position = position.linear_interpolate(focus_on.global_position, delta * 3)
		zoom = zoom.linear_interpolate(Vector2(focus_zoom, focus_zoom), delta * 3)
		unfocusing = true
	elif character_node != null:
		if !character_node.dead and !get_tree().paused:
			if unfocusing:
				position = position.linear_interpolate(character_node.global_position, delta * 9)
				if abs(position.distance_to(character_node.global_position)) < 15:
					unfocusing = false
			else:
				character_vel = character_vel.linear_interpolate(character_node.velocity * 15 * delta, delta * 2)
				position = character_node.global_position + character_vel

func load_in(_level_data : LevelData, level_area : LevelArea):
	var level_size = level_area.settings.size
	limit_right = level_size.x * 32
	limit_bottom = level_size.y * 32
	if focus_on != null:
		position = focus_on.global_position
	elif character_node != null:
		position = character_node.global_position
