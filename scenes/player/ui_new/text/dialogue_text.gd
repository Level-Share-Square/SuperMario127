extends Control

signal menu_opened
signal menu_closed

const TYPE_SPEED: float = 0.023
const FADE_TIME: float = 0.25

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
onready var page_change = $PageChange
onready var typing = $Typing

onready var tween = $Tween
onready var fade_tween = $FadeTween

var dialogue: PoolStringArray 
var last_tag: String

var player_expressions: Dictionary = {
	":Char:": "talking",
	":CharHappy:": "happy",
	":CharShocked:": "shocked",
	":CharAgree:": "nodding",
	":CharDisagree:": "disagree",
	":CharThink:": "thinking",
	":CharAngry:": "angry",
}
var player_speaking: bool

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
	else:
		page_change.play()
	close_label.bbcode_text = text_replace_util.parse_text("[center]Press :interactinput: to continue[/center]", character_node)
	name_label.bbcode_text = text_replace_util.parse_text(character_name, character_node)
	open = true
	
	last_tag = ""
	emit_signal("menu_opened")
	interact()


func player_speak(expression: String):
	player_speaking = true

	var last_focus: Node = character.camera.focus_on
	character.camera.focus_on = character.dialogue_focus
	character.anim_player.play(expression)
	
	character.auto_flip = false
	character.sprite.flip_h = (character.facing_direction < 0)
	
	yield(character.anim_player, "animation_finished")
	
	character.camera.focus_on = last_focus
	player_speaking = false


func interact():
	if is_instance_valid(character):
		character.inputs[Character.input_names.interact][1] = false
	if player_speaking: return
	
	var dialogue_page: int = dialogue_obj.page_cache
	
	if label.percent_visible == 1:
		for key in player_expressions.keys():
			if last_tag.begins_with(key) and character.is_grounded() and not is_instance_valid(character.state):
				last_tag = last_tag.trim_prefix(key)
				player_speak(player_expressions[key])
				yield(character.anim_player, "animation_finished")
		
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
	elif label.percent_visible == 1:
		page_change.play()
	
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
		if cur_text.length() > 0: 
			typing.play()
		
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
		typing.stop()
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
	typing.stop()
	
	character.velocity = stored_velocity
	stored_velocity = Vector2.ZERO
	
	character = null
	dialogue_obj = null
	emit_signal("menu_closed")


func _physics_process(delta):
	if !open or player_speaking:
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
