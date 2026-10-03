extends ScrollContainer


onready var layer_menu = $"%LayerMenu"
onready var vbox: VBoxContainer = $"%Layers"
export var max_height: float


func _ready():
	connect("resized", self, "resized")
	vbox.connect("resized", self, "resized")
	resized()


func resized():
	rect_min_size.y = min(vbox.rect_size.y, max_height)
	layer_menu.rect_size.y = 0 # weird that i have to update this...
