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
export var player_id: int = -1

## visuals
onready var action: Control = $HBoxContainer/Action
onready var sprite: AnimatedSprite = $HBoxContainer/Action/Sprite 

export var sprite_visible: bool = true
export var sprite_frames: SpriteFrames
export var sprite_animation: String
export var sprite_rotation: float
export var sprite_offset: Vector2

func _ready():
	if !Engine.is_editor_hint():
		if is_instance_valid(remapper):
			button.connect("pressed", remapper, "start_listening", [self, get_parent()])
			reset_button.connect("pressed", remapper, "reset_keybind", [self])
		change_button_text()
	update()

func pressed():
	update()


## button text
func return_default_text() -> String:
	var action = LocalSettings.load_setting(input_group, input_key, [])
	if action == []:
		return UNBOUND_TEXT
	
	return bindings_util.get_binding_human_name(action)

func change_button_text(new_text: String = ""):
	if new_text == "": 
		new_text = return_default_text()
	button.text = new_text


## label and sprite styling
func update():
	label.text = name.capitalize()
	label.text = label.text.replace("Ui", "UI")
	label.text = label.text.replace("Gp", "GP")
	
	## sprite stuff
	sprite.visible = sprite_visible
	if !sprite_visible: 
		label.align = Label.ALIGN_CENTER
		action.visible = false
		return
	
	sprite.frames = sprite_frames
	sprite.play(sprite_animation)
	sprite.rotation_degrees = sprite_rotation
	sprite.offset = sprite_offset
