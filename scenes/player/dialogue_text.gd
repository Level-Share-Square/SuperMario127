extends Control

const TYPE_SPEED = 0.035

var open := false
var normal_pos : Vector2
var transition_speed := 6.0

var character : Character
var dialogue_obj : Node2D

onready var label = $VBoxContainer/MarginContainer/RichTextLabel
onready var close_label = $VBoxContainer/CloseLabel
onready var name_label = $Panel/Name

onready var menu_open = $MenuOpen
onready var menu_close = $MenuClose

onready var tween = $Tween

var dialogue: PoolStringArray 
var dialogue_page: int

func _ready():
	normal_pos = rect_position
	
	rect_position = Vector2(normal_pos.x * 1.25, normal_pos.y * 1.2)
	rect_scale = Vector2(0.8, 0.8)
	modulate = Color(1, 1, 1, 0)

func open(_dialogue : PoolStringArray, dialogue_node : Node2D, character_node : Character, character_name : String):
	dialogue = _dialogue
	character = character_node
	dialogue_obj = dialogue_node
	
	menu_open.play()
	close_label.bbcode_text = text_replace_util.parse_text("[center]Press :interactinput: to continue[/center]", character_node)
	name_label.bbcode_text = character_name
	open = true
	
	dialogue_page = 0
	interact()

func interact():
	if label.percent_visible == 1:
		dialogue_page += 1
		tween.stop_all()
		
		if dialogue_page >= dialogue.size():
			close()
			return
	
	var cur_text = dialogue[dialogue_page].substr(4)
	var expression = int(dialogue[dialogue_page].left(2))
	var action = int(dialogue[dialogue_page].substr(2, 2))
	dialogue_obj.emit_signal("message_changed", expression, action)
	
	label.bbcode_text = text_replace_util.parse_text(cur_text, character)
	if not tween.is_active():
		tween.playback_speed = 1
		tween.interpolate_property(
			label, 
			"percent_visible", 
			0, 
			1, 
			cur_text.length() * TYPE_SPEED
		)
		tween.start()
	else:
		tween.playback_speed = INF

func close():
	open = false
	
	label.percent_visible = 0
	dialogue_obj.reset_read_timer = 0.5
	dialogue_obj.restore_control()
	menu_close.play()
	character = null
	dialogue_obj = null
	
func _physics_process(delta):
	if !open:
		rect_position = lerp(rect_position, Vector2(normal_pos.x * 1.25, normal_pos.y * 1.2), delta * transition_speed)
		rect_scale = lerp(rect_scale, Vector2(0.8, 0.8), delta * transition_speed)
		modulate = lerp(modulate, Color(1, 1, 1, 0), delta * transition_speed)
	else:
		#print(is_instance_valid(character))
		if is_instance_valid(character) and character.inputs[Character.input_names.interact][1] and !dialogue_obj.tween.is_active():
			interact()
		rect_position = lerp(rect_position, normal_pos, delta * transition_speed)
		rect_scale = lerp(rect_scale, Vector2(1, 1), delta * transition_speed)
		modulate = lerp(modulate, Color(1, 1, 1, 1), delta * transition_speed)
