extends EnemyBase


const DEFAULT_COLOR := Color.red

export var color := Color.red

var rainbow: bool = false setget set_rainbow 
var rainbow_color := Color(0.999, 0, 0) # so that it doesn't ever snap to the default color

onready var recolor_sprite: AnimatedSprite = $AnimatedSprite/RecolorSprite
onready var player_detector: Area2D = $PlayerDetector


func set_color(value: Color) -> void:
	color = value
	
	if color != DEFAULT_COLOR:
		var true_color: Color = color
		true_color.s /= 2
		recolor_sprite.visible = true
		recolor_sprite.self_modulate = true_color
	else:
		recolor_sprite.visible = false


func set_rainbow(value: bool) -> void:
	rainbow = value
	if is_instance_valid(damage):
		damage.bounce_type = EnemyDamage.BounceType.NORMAL if value else EnemyDamage.BounceType.SPRING


func _ready():
	set_color(color)
	set_rainbow(rainbow)


func _process(delta):
	if not rainbow: return
	rainbow_color.h += delta
	set_color(rainbow_color)


func _enter_tree():
	cur_state = "IdleState"


func set_default_state():
	set_state_by_name("IdleState")
