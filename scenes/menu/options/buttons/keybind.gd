tool
extends VBoxContainer

onready var label = $HBoxContainer/Label
onready var action = $HBoxContainer/Action
onready var sprite = $HBoxContainer/Action/Sprite 

# controls visuals
export var sprite_visible: bool = true
export var sprite_animation: String
export var sprite_rotation: float
export var sprite_offset: Vector2

func _ready():
	update()

func update():
	label.text = name.capitalize()
	
	sprite.visible = sprite_visible
	if !sprite_visible: 
		label.align = Label.ALIGN_CENTER
		action.visible = false
		return
		
	sprite.play(sprite_animation)
	sprite.rotation_degrees = sprite_rotation
	sprite.offset = sprite_offset
