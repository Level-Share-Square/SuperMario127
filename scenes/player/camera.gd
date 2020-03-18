extends Camera2D

export var character : NodePath

onready var character_node = get_node(character)

func _physics_process(delta):
	if character_node.controllable == true:
		position = character_node.position

func load_in(level_data : LevelData, level_area : LevelArea):
	var level_size = level_area.settings.size
	limit_right = level_size.x * 32
	limit_bottom = level_size.y * 32
	position = character_node.position
