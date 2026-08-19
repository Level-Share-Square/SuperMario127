class_name CollapsibleContainer
extends ButtonSound


export(NodePath) var selected_revealer_path
onready var selected_revealer: Control = get_node(selected_revealer_path)
onready var revealer_child: Control = selected_revealer.get_child(0)

var toggled = false


func _ready():
	connect("pressed", self, "on_pressed")
	selected_revealer.rect_min_size.y = 0
	
	
func on_pressed():
	.on_pressed()
	
	if !toggled:
		var tween = get_tree().create_tween()
		tween.tween_property(selected_revealer, "rect_min_size:y", revealer_child.rect_size.y, 0.3).set_trans(Tween.TRANS_CUBIC)
		toggled = true
		text = text.replace(">", "V")
		return
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(selected_revealer, "rect_min_size:y", 0, 0.3).set_trans(Tween.TRANS_CUBIC)
		toggled = false
		text = text.replace("V", ">")
		return
