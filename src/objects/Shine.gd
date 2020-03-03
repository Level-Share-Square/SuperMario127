extends GameAreaCollisionObject

signal on_collect
onready var sound := AudioStreamPlayer.new()
onready var music := get_node("../../Music")
onready var character = get_node("../../Character")
var effects_instance

var collected = false

func collect(body):
	if !collected && body == character && character.controllable:
		character.controllable = false
		character.set_state_by_name("Fall", 0)
		character.velocity = Vector2(0, 0)
		sound.play()
		music.stop()
		collected = true
		visible = false
		emit_signal("on_collect")

func _ready():
	var sprite_frames = load("res://assets/textures/items/shine_sprite/game.tres")
	var shine_effects = load("res://assets/textures/items/shine_sprite/shine_effects.tscn")
	effects_instance = shine_effects.instance()
	add_child(effects_instance)
	frames = sprite_frames
	light_mask = 2
	playing = true
	shape.scale = Vector2(0.5, 0.5)
	connect("on_collide", self, "collect")
	var stream = load("res://assets/sounds/shine.wav")
	sound.stream = stream
	sound.volume_db = 5;
	add_child(sound)
	
func _physics_process(delta):
	if collected and character.is_grounded():
		character.exit()
	elif collected:
		var sprite = character.get_node("AnimatedSprite")
		sprite.animation = "shineFall"
	effects_instance.rotation_degrees += 0.5
