extends Node


export var url: String


func _ready():
	get_parent().connect("pressed", self, "load_url")


func load_url():
	OS.shell_open(url)
