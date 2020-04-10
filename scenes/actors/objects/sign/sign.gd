extends GameObject

onready var area = $Area2D
var text := "This is a sign. Click on it in the editor to edit!"
var character

func _set_properties():
	savable_properties = ["text"]
	editable_properties = ["text"]
	
func _set_property_values():
	set_property("text", text, true)

func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "enter_area")
		var _connect2 = area.connect("body_exited", self, "exit_area")

func enter_area(body):
	if body.name.begins_with("Character"):
		character = body
		
func exit_area(body):
	if body == character:
		character = null
		
func _physics_process(delta):
	if character != null:
		if character.interact_just_pressed:
			print("A")
