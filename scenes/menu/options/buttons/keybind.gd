tool
extends VBoxContainer
class_name KeybindButton

## auto setup
export var remapper_path: NodePath
onready var remapper: Control = get_node(remapper_path)

## consts
const UNBOUND_TEXT: String = "Unbound"

onready var label: Label = $HBoxContainer/Label
onready var button: Button = $Button
onready var reset_button = $Button/Reset

## binding
export var input_group: String
export var input_key: String

## visuals
onready var action: Control = $HBoxContainer/Action
onready var sprite: AnimatedSprite = $HBoxContainer/Action/Sprite 

export var sprite_visible: bool = true
export var sprite_animation: String
export var sprite_rotation: float
export var sprite_offset: Vector2

func _ready():
	if is_instance_valid(remapper):
		button.connect("pressed", remapper, "start_listening", [self, get_parent()])
	update()

func pressed():
	get_focus_owner().release_focus()
	update()

func update():
	label.text = name.capitalize()
	
	## sprite stuff
	sprite.visible = sprite_visible
	if !sprite_visible: 
		label.align = Label.ALIGN_CENTER
		action.visible = false
		return
	
	sprite.play(sprite_animation)
	sprite.rotation_degrees = sprite_rotation
	sprite.offset = sprite_offset

func change_button_text(new_text: String):
	if new_text == "": 
		new_text = UNBOUND_TEXT
	button.text = new_text
