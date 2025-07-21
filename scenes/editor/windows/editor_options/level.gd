extends MarginContainer

onready var level_name = get_node("%Level Name")
onready var author = get_node("%Author")
onready var description = get_node("%Description")
onready var thumbnail_url = get_node("%Thumbnail URL")
onready var window = owner


# Called when the node enters the scene tree for the first time.
func _process(delta):
	owner.level_name = level_name
	owner.author = author
	owner.description = description
	owner.thumbnail_url = thumbnail_url
	
	#you may be asking why i did this here instead of in the editor options window
	#the truth is that i made this script then realized i could just do it over there
	#by then, it was already over
	#im upset


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
