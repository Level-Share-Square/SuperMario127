tool
extends VBoxContainer

## auto setup
export var remapper_path: NodePath
onready var remapper: Control = get_node(remapper_path)

## consts
const ON_TEXT: String = "On"
const OFF_TEXT: String = "Off"

onready var label: Label = $HBoxContainer/Label
onready var button: Button = $Button

## binding
export var input_group: String
export var input_key: String

# this could be done cleaner, but i don't think its that important right now
onready var reset_button = $Button/Reset
export var is_bool: bool
var bool_value: bool

## visuals
onready var action: Control = $HBoxContainer/Action
onready var sprite: AnimatedSprite = $HBoxContainer/Action/Sprite 

export var sprite_visible: bool = true
export var sprite_animation: String
export var sprite_rotation: float
export var sprite_offset: Vector2

func _ready():
	if is_instance_valid(remapper):
		button.connect("pressed", remapper, "start_listening", [self])
	
	if is_bool:
		bool_value = LocalSettings.load_setting(input_group, input_key, false)
	update()

func pressed():
	if is_bool:
		bool_value = !bool_value
		LocalSettings.change_setting(input_group, input_key, bool_value)
	
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
	
	if is_bool:
		button.text = ON_TEXT if bool_value else OFF_TEXT
		return


func change_button_text(new_text: String):
	button.text = new_text
