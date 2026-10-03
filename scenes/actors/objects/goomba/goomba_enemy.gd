extends EnemyBase


const DEFAULT_COLOR := Color.red
export var color := DEFAULT_COLOR

var rainbow: bool = false setget set_rainbow 

onready var player_detector: Area2D = $PlayerDetector
onready var enemy_sprite: AnimatedSprite = $AnimatedSprite


func set_color(value: Color) -> void:
	if is_instance_valid(enemy_sprite): enemy_sprite.set_color(value)


func set_rainbow(value: bool) -> void:
	rainbow = value
	if is_instance_valid(enemy_sprite): enemy_sprite.rainbow = value


func _ready():
	set_color(color)
	set_rainbow(rainbow)


func _enter_tree():
	cur_state = "IdleState"


func set_default_state():
	set_state_by_name("IdleState")
