extends Node

var success_img = "res://scenes/shared/notification/assets/success.png"
var warning_img = "res://scenes/shared/notification/assets/warning.png"
var error_img = "res://scenes/shared/notification/assets/error.png"

# PROTOTYPE

const offset = 5
var biggest_y = offset
var notifications : Array

func success(title : String, content : String, duration : int = 2):
	_instantiate(title, content, success_img, duration)

func warning(title : String, content : String, duration : int = 2):
	_instantiate(title, content, warning_img, duration)
	
func error(title : String, content : String, duration : int = 2):
	_instantiate(title, content, error_img, duration)

func _instantiate(title : String, content : String, type : String, duration : int):
	var ui = get_tree().get_current_scene().get_node("UI")
	
	var notification = load("res://scenes/shared/notification/notification.tscn")
	var notification_instance : Control = notification.instance()
	
	notifications.append(notification_instance)

	var result_x = ProjectSettings.get_setting("display/window/size/width") - notification_instance.get_rect().size.x
	
	notification_instance.set_position(Vector2(result_x - offset, biggest_y))
	biggest_y += notification_instance.rect_size.y + offset
	
	notification_instance.set_title(title)
	notification_instance.set_content(content)
	notification_instance.set_texture(type)
	notification_instance.set_duration(duration)
	
	ui.add_child(notification_instance)
	notification_instance.init()
