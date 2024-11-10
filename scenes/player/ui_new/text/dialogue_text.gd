extends Control

signal menu_opened
signal menu_closed

const TYPE_SPEED: float = 0.035

var open := false
var normal_pos: Vector2
var transition_speed := 6.0

var character: Character
var dialogue_obj: Node2D
var stored_velocity: Vector2

onready var label = $VBoxContainer/MarginContainer/RichTextLabel
onready var close_label = $VBoxContainer/CloseLabel
onready var name_label = $Name

onready var menu_open = $MenuOpen
onready var menu_close = $MenuClose

onready var tween = $Tween

var dialogue: PoolStringArray 
var last_tag: String

func _ready():
	normal_pos = rect_position
	label.percent_visible = 0
	
	rect_position = Vector2(normal_pos.x * 1.25, normal_pos.y * 1.2)
	rect_scale = Vector2(0.8, 0.8)
	modulate = Color(1, 1, 1, 0)

func open(_dialogue : PoolStringArray, dialogue_node : Node2D, character_node : Character, character_name : String):
	Singleton.CurrentLevelData.can_pause = false
	
	dialogue = _dialogue
	character = character_node
	dialogue_obj = dialogue_node
	
	if not open:
		menu_open.play()
	close_label.bbcode_text = text_replace_util.parse_text("[center]Press :interactinput: to continue[/center]", character_node)
	name_label.bbcode_text = character_name
	open = true
	
	last_tag = ""
	emit_signal("menu_opened")
	interact()

func interact():
	var dialogue_page: int = dialogue_obj.page_cache
	
	if label.percent_visible == 1:
		dialogue_page += 1
		dialogue_obj.page_cache += 1
		tween.stop_all()
		
		var tagged_node: Node = get_dialogue_from_tag(last_tag)
		if is_instance_valid(tagged_node):
			last_tag = ""
			label.percent_visible = 0
			tagged_node.being_read = false
			tagged_node.open_menu(character)
			return
	
	if dialogue_obj.page_cache >= dialogue.size():
		close()
		return
	
	var page_text: String = dialogue[dialogue_page]
	var colon_offset: int = page_text.find(";")
	
	var cur_text: String = page_text.substr(colon_offset + 1)
	var tag: String = page_text.substr(4, colon_offset - 4)
	
	last_tag = tag
	
	var expression: int = int(page_text.left(2))
	var action: int = int(page_text.substr(2, 2))
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

func get_dialogue_from_tag(tag: String) -> Node:
	if tag == "": return null
	for node in get_tree().get_nodes_in_group("TaggedDialogue"):
		if node.tag == tag: return node
	return null

func close():
	Singleton.CurrentLevelData.can_pause = true
	open = false
	
	label.percent_visible = 0
	menu_close.play()
	
	character.velocity = stored_velocity
	stored_velocity = Vector2.ZERO
	
	character = null
	dialogue_obj = null
	emit_signal("menu_closed")

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
