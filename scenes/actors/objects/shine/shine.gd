extends GameObject

onready var effects = $ShineEffects
onready var area = $Area2D
onready var sound = $CollectSound
var collected = false
var character

var shine_name := "Unnamed Shine"
var shine_description := "This is a shine! Collect it to win the level."

func _set_properties():
	savable_properties = ["shine_name", "shine_description"]
	
func _set_property_values():
	set_property("shine_name", shine_name, true)
	set_property("shine_description", shine_description, true)

func collect(body):
	if !collected && body.name.begins_with("Character") && body.controllable:
		character = body
		character.set_state_by_name("Fall", 0)
		character.velocity = Vector2(0, 0)
		character.get_node("Sprite").rotation_degrees = 0
		character.controllable = false
		#sound.play() -Sound doesn't carry over between scenes, so it cuts off
		collected = true
		visible = false
		emit_signal("on_collect")

func _ready():
	if mode != 1:
		area.connect("body_entered", self, "collect")

func _physics_process(delta):
	effects.rotation_degrees += 0.5
	if collected:
		var sprite = character.get_node("Sprite")
		sprite.animation = "shineFall"
		if character.is_grounded():
			character.exit()
