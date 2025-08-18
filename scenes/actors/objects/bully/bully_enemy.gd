extends EnemyBase


const DEFAULT_COLOR := Color.red

export var horn_color := Color.red

onready var recolor_sprite: AnimatedSprite = $AnimatedSprite/RecolorSprite
onready var player_detector: Area2D = $PlayerDetector
onready var animation_player = get_node("%AnimationPlayer")


func set_color(value: Color) -> void:
	horn_color = value
	
	if horn_color != DEFAULT_COLOR:
		var true_color = horn_color
		true_color.s /= 1.5
		
		recolor_sprite.visible = true
		recolor_sprite.self_modulate = true_color
	else:
		recolor_sprite.visible = false


func _ready():
	set_color(horn_color)


func _enter_tree():
	cur_state = "IdleState"
