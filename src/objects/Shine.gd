extends GameAreaCollisionObject

signal on_collect
onready var sound := AudioStreamPlayer.new()
onready var music := get_node("../../Music")
onready var character = get_node("../../Character")

var collected = false

func collect(body):
	if !collected && body == character:
		character.controllable = false
		character.velocity = Vector2(0, 0)
		sound.play()
		music.stop()
		collected = true
		animation = "collect"
		emit_signal("on_collect")

func _ready():
	var sprite_frames = load("res://assets/textures/items/shine_sprite/game.tres")
	frames = sprite_frames
	playing = true
	shape.scale = Vector2(0.5, 0.5)
	connect("on_collide", self, "collect")
	var stream = load("res://assets/sounds/shine.wav")
	sound.stream = stream
	sound.volume_db = 5;
	add_child(sound)
	
func _physics_process(delta):
	if collected and character.is_grounded():
		character.kill()
