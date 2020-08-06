extends Node

var success = "res://scenes/shared/notification/assets/success.png"
var warning = "res://scenes/shared/notification/assets/warning.png"
var error = "res://scenes/shared/notification/assets/error.png"

# PROTOTYPE

const offset = 5
var biggest_y = offset
var notifications : Array

func success(title : String, content : String):
	_instantiate(title, content, success)

func warning(title : String, content : String):
	_instantiate(title, content, warning)
	
func error(title : String, content : String):
	_instantiate(title, content, error)

func _instantiate(title : String, content : String, type : String):
	var ui = get_tree().get_current_scene().get_node("UI")
	
	var notification = load("res://scenes/shared/notification/notification.tscn")
	var notification_instance : Control = notification.instance()
	
	notifications.append(notification_instance)

	var result_x = ProjectSettings.get_setting("display/window/size/width") - notification_instance.get_rect().size.x
	
	notification_instance.set_position(Vector2(result_x - offset, biggest_y))
	biggest_y += notification_instance.rect_size.y
	
	notification_instance.set_title(title)
	notification_instance.set_content(content)
	notification_instance.set_texture(type)
	ui.add_child(notification_instance)
	notification_instance.init()
