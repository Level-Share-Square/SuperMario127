extends Label

onready var timer = $Timer
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	#gets the editor and connects it to updating the zoom
	get_tree().get_current_scene().connect("zoom_changed", self, "update_zoom_display")

func update_zoom_display(zoom) -> void:
	timer.stop()
	timer.disconnect("timeout", self, "hide_zoom_display")
	
	text = "x" + "%0.2f" % zoom
	
	show_zoom_display()
	timer.start(2.5)
	timer.connect("timeout", self, "hide_zoom_display")

func show_zoom_display() -> void:
	if !(rect_position.x == 8):
		tween.interpolate_property(self, "rect_position", rect_position, Vector2(8, 76), .15, Tween.TRANS_QUAD)
		tween.start()

func hide_zoom_display() -> void:
	if !(rect_position.x == -64) and !tween.is_active():
		tween.interpolate_property(self, "rect_position", Vector2(8, 76), Vector2(-72, 76), .5, Tween.TRANS_QUAD)
		tween.start()
