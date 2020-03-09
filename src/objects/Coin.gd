extends GameAreaCollisionObject

signal on_collect
onready var sound := AudioStreamPlayer.new()
onready var character = get_node("../../Character")

var collected = false
var destroy_timer = 0.0

func collect(body):
	if !collected && body == character && character.controllable:
		sound.play()
		collected = true;
		animation = "collect"
		emit_signal("on_collect")
		destroy_timer = 2

func _ready():
	var sprite_frames = preload("res://assets/textures/items/coins/yellow.tres")
	frames = sprite_frames
	playing = true
	shape.scale = Vector2(1.5, 1.5)
	connect("on_collide", self, "collect")
	var stream = preload("res://assets/sounds/coin.wav")
	sound.stream = stream
	sound.volume_db = 5;
	add_child(sound)
	
func _physics_process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			destroy()
