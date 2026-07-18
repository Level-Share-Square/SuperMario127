class_name CollapsibleContainer
extends Button

export(NodePath) var selected_container_path
onready var selected_container: Control = get_node(selected_container_path)

var toggled = false
var min_size: float

func _ready():
	connect("button_down", self, "on_pressed")
	selected_container.rect_scale.y = 0
	
func _process(_delta):
	if get_parent().name == "PresetMusic":
#		print(selected_container.rect_scale.y)
		pass
	
func on_pressed():
	if !toggled:
		var tween = get_tree().create_tween()
		selected_container.rect_scale.y = 0
		tween.tween_property(selected_container, "rect_scale:y", 0.2, 0.3).set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "tween_finished", [tween])
		toggled = true
		text = text.replace(">", "V")
		return
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(selected_container, "rect_scale:y", 0, 0.3).set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "tween_finished", [tween])
		toggled = false
		text = text.replace("V", ">")
		return
		
func tween_finished(tween):
	print("ayee")
