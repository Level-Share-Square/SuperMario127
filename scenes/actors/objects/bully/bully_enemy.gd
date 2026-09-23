extends EnemyBase


const DEFAULT_HORN_COLOR := Color.yellow
const DEFAULT_FEET_COLOR := Color.green

export var horn_color := Color.yellow setget set_horn_color
export var feet_color := Color.green setget set_feet_color

onready var player_detector: Area2D = $PlayerDetector
onready var animation_player = get_node("%AnimationPlayer")

var rainbow := false
var rainbow_color := Color(0.999, 0, 0) # so that it doesn't ever snap to the default color


func set_horn_color(value: Color) -> void:
	horn_color = value
	if is_instance_valid(sprite): sprite.set_horn_color(value)

func set_feet_color(value: Color) -> void:
	feet_color = value
	if is_instance_valid(sprite): sprite.set_feet_color(value)
	
func set_rainbow(value: bool) -> void:
	rainbow = value
	if is_instance_valid(sprite): sprite.set_rainbow(value)

func _ready():
	sprite.set_horn_color(horn_color)
	sprite.set_feet_color(feet_color)
	sprite.set_rainbow(rainbow)


func _enter_tree():
	cur_state = "IdleState"
