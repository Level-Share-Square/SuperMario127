extends HBoxContainer

onready var viewport1 = $ViewportContainer/Viewport
onready var viewport2 = $ViewportContainer2/Viewport

func _ready():
	viewport2.world_2d = viewport1.world_2d
