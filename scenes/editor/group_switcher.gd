extends Button

export var text_edit_path : NodePath
onready var text_edit_node = get_node(text_edit_path)

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var switch_to_group : Object
var last_hovered = false
var group_picker : Object

func _pressed():
	group_picker.group = switch_to_group.id
	group_picker.change_group()
	
func _ready():
	$Label.text = switch_to_group.name
	self_modulate = switch_to_group.color

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
