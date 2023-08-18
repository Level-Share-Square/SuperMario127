extends TextEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	call_deferred("_hide_scrollbar")

func _on_TextEdit_text_changed():
	call_deferred("_hide_scrollbar")
  
func _hide_scrollbar():
	for child in get_children():
		if child is VScrollBar:
			child.modulate.a = 0
		elif child is HScrollBar:
			child.modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
