extends Sprite

onready var cannon_moveable = get_parent().get_parent()

const INITIAL_HIDE_POSITION = -15
const INITIAL_CANNON_MOVABLE_POSITION_Y = 37

func _ready():
	set_process(false)

func _process(_delta):
	material.set_shader_param("hidePosition", INITIAL_HIDE_POSITION + (INITIAL_CANNON_MOVABLE_POSITION_Y - cannon_moveable.position.y))
