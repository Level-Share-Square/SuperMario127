class_name CollapsibleContainer
extends Button

export(NodePath) var selected_container_path
onready var selected_container: Control = get_node(selected_container_path)

var toggled = false
var min_size: float

func _ready():
	connect("button_down", self, "on_pressed")
	selected_container.rect_min_size = selected_container.get_child(0).rect_size
	min_size = selected_container.rect_min_size.y
	selected_container.rect_min_size.y = 0
	
func on_pressed():
	if !toggled:
		var tween = get_tree().create_tween()
		tween.tween_property(selected_container, "rect_min_size:y", min_size, 0.3).set_trans(Tween.TRANS_CUBIC)
		toggled = true
		text = text.replace(">", "V")
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(selected_container, "rect_min_size:y", 0, 0.3).set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "tween_finished", [tween])
		toggled = false
		text = text.replace("V", ">")
		
func tween_finished(tween):
	tween.kill()
