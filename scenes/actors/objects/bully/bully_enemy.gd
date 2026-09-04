extends EnemyBase


const DEFAULT_HORN_COLOR := Color.yellow
const DEFAULT_FEET_COLOR := Color.green

export var horn_color := Color.yellow setget set_horn_color
export var feet_color := Color.green setget set_feet_color

onready var horn_sprite: AnimatedSprite = $AnimatedSprite/RecolorSpriteHorns
onready var feet_sprite: AnimatedSprite = $AnimatedSprite/RecolorSpriteFeet
onready var player_detector: Area2D = $PlayerDetector
onready var animation_player = get_node("%AnimationPlayer")

var rainbow: bool
var rainbow_color := Color(0.999, 0, 0) # so that it doesn't ever snap to the default color


func set_horn_color(value: Color) -> void:
	horn_color = value
	
	if not is_instance_valid(horn_sprite):
		return
	
	if not horn_color.is_equal_approx(DEFAULT_HORN_COLOR):
		var true_color = horn_color
		#true_color.s /= 1.5
		
		horn_sprite.visible = true
		horn_sprite.self_modulate = true_color
	else:
		horn_sprite.visible = false


func set_feet_color(value: Color) -> void:
	feet_color = value
	
	if not is_instance_valid(feet_sprite):
		return
	
	if not feet_color.is_equal_approx(DEFAULT_FEET_COLOR):
		var true_color = feet_color
		#true_color.s /= 1.5
		
		feet_sprite.visible = true
		feet_sprite.self_modulate = true_color
	else:
		feet_sprite.visible = false


func _ready():
	set_horn_color(horn_color)
	set_feet_color(feet_color)


func _process(delta):
	if not rainbow: return
	rainbow_color.h += delta
	set_horn_color(rainbow_color)
	set_feet_color(rainbow_color)


func _enter_tree():
	cur_state = "IdleState"
