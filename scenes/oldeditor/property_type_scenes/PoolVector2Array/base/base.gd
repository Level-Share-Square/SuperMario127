extends Control

export var line_edit : NodePath

var pressed = false
var last_hovered = false
var point_editor_scene

var value : PoolVector2Array setget set_value, get_value

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
onready var text = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	text.connect("button_down", self, "pressed")

func _process(_delta):
	if text.is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = text.is_hovered()

func pressed():
	click_sound.play()
	update_value()
	point_editor_scene = ResourceLoader.load("res://scenes/editor/property_type_scenes/PoolVector2Array/base/PointToolController.tscn").instance()
	point_editor_scene.editing_object = get_parent().object
	get_tree().get_current_scene().get_node("UI").add_child(point_editor_scene)
	point_editor_scene.initialize(self)
		
func set_value(new_value):
	value = new_value
	if len(value) == 0:
		value.push_back(get_parent().object.global_position)

func get_value():
	return value

func update_value():
	get_parent().update_value(get_value())
