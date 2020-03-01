extends GameObject

signal on_collect
onready var area := Area2D.new()
onready var shape := CollisionShape2D.new()
onready var sound := AudioStreamPlayer.new()

var collected = false
var destroy_timer = 0.0

func destroy():
	queue_free()

func collect(body):
	if !collected:
		sound.play()
		collected = true;
		animation = "collect"
		emit_signal("on_collect")
		destroy_timer = 2

func _ready():
	var sprite_frames = load("res://assets/textures/items/coins/yellow.tres")
	frames = sprite_frames
	playing = true
	shape.shape = RectangleShape2D.new()
	shape.scale = Vector2(1.5, 1.5)
	area.connect("body_entered", self, "collect")
	area.add_child(shape)
	add_child(area)
	var stream = load("res://assets/sounds/coin.wav")
	sound.stream = stream
	sound.volume_db = 5;
	add_child(sound)
	
func _physics_process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			destroy()
