extends CanvasLayer


func _ready():
	Singleton.PhotoMode.connect("photo_mode_changed", self, "toggle_photo_mode")


func toggle_photo_mode():
	visible = not Singleton.PhotoMode.enabled
