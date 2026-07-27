extends ScrollContainer


onready var vbox: VBoxContainer = get_child(0) 
export var max_height: float


func _ready():
	connect("resized", self, "resized")
	resized()


func resized():
	rect_min_size.y = min(vbox.rect_size.y, max_height)
