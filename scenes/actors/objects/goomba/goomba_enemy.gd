extends EnemyBase


const DEFAULT_COLOR := Color.red

export var color := Color.red

onready var recolor_sprite: AnimatedSprite = $AnimatedSprite/RecolorSprite
onready var player_detector: Area2D = $PlayerDetector

func set_color(value: Color) -> void:
	color = value
	
	if color != DEFAULT_COLOR:
		var true_color = color
		true_color.s /= 1.5
		
		recolor_sprite.visible = true
		recolor_sprite.self_modulate = true_color
	else:
		recolor_sprite.visible = false


func _ready():
	set_color(color)


func _enter_tree():
	cur_state = "IdleState"


func set_default_state():
	set_state_by_name("IdleState")
