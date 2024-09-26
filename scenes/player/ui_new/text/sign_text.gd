extends Control

var open := false
var normal_pos : Vector2
var transition_speed := 6.0

var character : Character
var sign_obj : Node2D

onready var label = $VBoxContainer/MarginContainer/RichTextLabel
onready var close_label = $VBoxContainer/CloseLabel

onready var menu_open = $MenuOpen
onready var menu_close = $MenuClose

func _ready():
	normal_pos = rect_position
	
	rect_position = Vector2(normal_pos.x * 1.25, normal_pos.y * 1.2)
	rect_scale = Vector2(0.8, 0.8)
	modulate = Color(1, 1, 1, 0)

func open(text : String, sign_node : Node2D, character_node : Character):
	Singleton.CurrentLevelData.can_pause = false
	
	character = character_node
	sign_obj = sign_node
	menu_open.play()
	label.bbcode_text = "[center]" + text_replace_util.parse_text(text, character) + "[/center]"
	close_label.bbcode_text = text_replace_util.parse_text("[center]Press :interactinput: to close[/center]", character_node)
	open = true

func close():
	Singleton.CurrentLevelData.can_pause = true
	
	open = false
	sign_obj.reset_read_timer = 0.5
	sign_obj.restore_control()
	menu_close.play()
	character = null
	sign_obj = null
	
func _physics_process(delta):
	if !open:
		rect_position = lerp(rect_position, Vector2(normal_pos.x * 1.25, normal_pos.y * 1.2), delta * transition_speed)
		rect_scale = lerp(rect_scale, Vector2(0.8, 0.8), delta * transition_speed)
		modulate = lerp(modulate, Color(1, 1, 1, 0), delta * transition_speed)
	else:
		#print(is_instance_valid(character))
		if is_instance_valid(character) and character.inputs[Character.input_names.interact][1] and !sign_obj.tween.is_active():
			close()
		rect_position = lerp(rect_position, normal_pos, delta * transition_speed)
		rect_scale = lerp(rect_scale, Vector2(1, 1), delta * transition_speed)
		modulate = lerp(modulate, Color(1, 1, 1, 1), delta * transition_speed)
