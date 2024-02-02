extends Control

export var button : NodePath

onready var button_node : Button = get_node(button)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
onready var path_editor_scene
var value: Curve2D
var last_hovered = false

func _ready():
	var _connect = button_node.connect("pressed", self, "pressed")

func pressed():
	click_sound.play()
	update_value()
	path_editor_scene = ResourceLoader.load("res://scenes/editor/property_type_scenes/Path/PathToolController.tscn").instance()
	path_editor_scene.editing_object = get_parent().object
	get_tree().get_current_scene().get_node("UI").add_child(path_editor_scene)
	path_editor_scene.initialize(self)

func set_value(_value: Curve2D):
	value = _value
	if value.get_point_count() == 0:
		value.add_point(get_parent().object.global_position)
	
	# Does object have a name for the value?
	var p := get_parent()
	if p.object.property_value_to_name.has(p.key) && p.object.property_value_to_name[p.key].has(value):
		button_node.text = value.name
	else:
		# Default to true/false otherwise
		button_node.text = "Edit path" if value else "False"

func get_value() -> Curve2D:
	return value

func update_value():
	get_parent().update_value(get_value())

func _process(_delta):
	if button_node.is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = button_node.is_hovered()
