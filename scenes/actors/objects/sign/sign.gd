extends GameObject

onready var area = $MessageArea
onready var animation_player = $AnimationPlayer
onready var pop_up = $Message
onready var sprite = $Sprite
var text := "This is a sign. Click on it in the editor to edit this text!"
var character

var normal_pos : Vector2
var transition_speed := 10.0

func _set_properties():
	savable_properties = ["text"]
	editable_properties = ["text"]
	
func _set_property_values():
	set_property("text", text, true)

func _ready():
	if !visible and mode != 1:
		visible = true
		sprite.visible = false
	
	if !enabled:
		pop_up.visible = false
	
	normal_pos = pop_up.position
	pop_up.position = Vector2(normal_pos.x * 0.8, normal_pos.y * 0.7)
	pop_up.scale = Vector2(0.8, 0.8)
	pop_up.modulate = Color(1, 1, 1, 0)
	$Message/Label.bbcode_text = "[center]" + text + "[/center]"
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
	if character == null:
		pop_up.position = lerp(pop_up.position, Vector2(normal_pos.x * 0.8, normal_pos.y * 0.7), delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(0.8, 0.8), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 0), delta * transition_speed)
	else:
		pop_up.position = lerp(pop_up.position, normal_pos, delta * transition_speed)
		pop_up.scale = lerp(pop_up.scale, Vector2(1, 1), delta * transition_speed)
		pop_up.modulate = lerp(pop_up.modulate, Color(1, 1, 1, 1), delta * transition_speed)
