extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var switch_to_group : Object
var last_hovered = false
var group_picker : Object

func _pressed():
	group_picker.group = switch_to_group.name
	group_picker.change_group()
	
func _ready():
	$Label.text = switch_to_group.group_name
	self_modulate = switch_to_group.color

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
