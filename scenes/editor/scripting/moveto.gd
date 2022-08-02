extends NinePatchRect

onready var scripting = get_parent()
onready var camera = $"../PanningCamera2D"
onready var move = $Area2D
var text_change = false
var can_drag

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	move.connect("area_entered", self, "_on_mouse_entered")
	move.connect("area_exited", self, "_on_mouse_exited")

# Called every frame. 'delta' is the elapsed time since the previous frame.



func _input(event: InputEvent) -> void:
	if can_drag == true:
		if event is InputEventMouseMotion:
			if event.button_mask == BUTTON_LEFT:
				rect_position += event.relative * camera.zoom

func _on_mouse_entered(area):
	can_drag = true
	camera.can_drag = false
func _on_mouse_exited(area):
	can_drag = false
	camera.can_drag = true

