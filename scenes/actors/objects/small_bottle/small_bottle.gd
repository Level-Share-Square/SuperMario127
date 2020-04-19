extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var sound = $AudioStreamPlayer

var collected = false
var respawn_timer = 0.0
		
func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		sound.play()
		sprite.visible = false
		respawn_timer = 40.0
		body.fuel += 15
		if body.fuel > 100:
			body.fuel = 100
		collected = true

func _ready():
	var _connect = area.connect("body_entered", self, "collect")
	
func _process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			sprite.visible = true
			collected = false
