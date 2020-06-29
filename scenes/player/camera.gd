extends Camera2D

export var character : NodePath

onready var character_node = get_node(character)

func _physics_process(_delta):
	if character_node != null:
		if !character_node.dead:
			position = character_node.position

func load_in(_level_data : LevelData, level_area : LevelArea):
	var level_size = level_area.settings.size
	limit_right = level_size.x * 32
	limit_bottom = level_size.y * 32
	if character_node != null:
		position = character_node.position
