extends GameObject

onready var area = $Area2D
onready var sprite = $Sprite

export(Array, Texture) var palette_textures

var stored_character : Character

func kill(body):
	if !enabled or body.invincible or body.invulnerable:
		return
	
	body.damage()

func _process(delta):
	if is_instance_valid(stored_character):
		kill(stored_character)

func body_entered(body):
	if !is_instance_valid(stored_character) and body.name.begins_with("Character"):
		stored_character = body

func body_exited(body):
	if body == stored_character:
		stored_character = null

func _ready():
	var _connect = area.connect("body_entered", self, "body_entered")
	_connect = area.connect("body_exited", self, "body_exited")
	if palette != 0:
		sprite.texture = palette_textures[palette - 1]
