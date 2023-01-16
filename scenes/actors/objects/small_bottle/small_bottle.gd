extends GameObject

onready var sprite = $Sprite
onready var area = $Area2D
onready var sound = $AudioStreamPlayer

var respawns := true
var collected = false
var respawn_timer = 0.0

func _set_properties() -> void:
	savable_properties = ["respawns"]
	editable_properties = ["respawns"]
	
func _set_property_values() -> void:
	set_property("respawns", respawns, true)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		sound.play()
		sprite.visible = false
		if respawns:
			respawn_timer = 40.0
		else:
			respawn_timer = 0 #If the timer's value is 0, the bottle will not respawn
		body.fuel += 15
		if body.fuel > 100:
			body.fuel = 100
		collected = true

func _ready():
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	var _connect = area.connect("body_entered", self, "collect")
	
func _process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_timer = 0
			sprite.visible = true
			collected = false
