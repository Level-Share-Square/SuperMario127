extends GameObject

onready var effects = $ShineEffects
onready var area = $Area2D
onready var sound = $CollectSound
var collected = false
var character

var title := "Unnamed Shine"
var description := "This is a shine! Collect it to win the level."
var show_in_menu := false

func _set_properties():
	savable_properties = ["title", "description", "show_in_menu"]
	editable_properties = ["title", "description", "show_in_menu"]
	
func _set_property_values():
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body
		character.set_state_by_name("Fall", 0)
		character.velocity = Vector2(0, 0)
		character.get_node("Sprite").rotation_degrees = 0
		character.controllable = false
		#sound.play() -Sound doesn't carry over between scenes, so it cuts off
		collected = true
		visible = false

func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "collect")

func _physics_process(_delta):
	effects.rotation_degrees = (OS.get_ticks_msec()/16) % 360
	if collected:
		var sprite = character.get_node("Sprite")
		sprite.animation = "shineFall"
		if character.is_grounded():
			character.exit()
