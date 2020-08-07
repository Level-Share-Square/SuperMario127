extends Control

var hiding = false

func init():
	$NinePatchRect/Tween.interpolate_property($NinePatchRect, "rect_scale",
			Vector2(0, 0), Vector2(1, 1), 0.5,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
	$NinePatchRect/Tween.start()
	$NinePatchRect/Tween.connect("tween_all_completed", self, "start_timer")
	$NinePatchRect.connect("gui_input", self, "press")

func hide():
	if !hiding:
		hiding = true
		$NinePatchRect/Tween.interpolate_property($NinePatchRect, "rect_scale",
				Vector2(1, 1), Vector2(0, 0), 0.5,
				Tween.TRANS_CIRC, Tween.EASE_OUT)
		$NinePatchRect/Tween.start()
		$NinePatchRect/Tween.connect("tween_all_completed", self, "self_destruct")

func press(event):
	if event is InputEventMouseButton && !hiding:
		$NinePatchRect/Timer.stop()
		hide()

func set_title(title : String):
	$NinePatchRect/Title.text = title

func set_content(content : String):
	$NinePatchRect/Content.text = content

func set_texture(type : String):
	$NinePatchRect.texture = load(type)

func set_duration(duration : int):
	$NinePatchRect/Timer.wait_time = duration

func start_timer():
	$NinePatchRect/Timer.connect("timeout", self, "hide")
	
func self_destruct():
	for notification in NotificationHandler.notifications:
		if notification.get_rect().position.y > get_rect().position.y:
			notification.rect_position -= Vector2(0, rect_size.y + NotificationHandler.offset)
	NotificationHandler.notifications.erase(self)
	NotificationHandler.biggest_y -= rect_size.y + NotificationHandler.offset
	queue_free()
