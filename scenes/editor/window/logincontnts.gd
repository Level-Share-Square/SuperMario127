extends TextEdit
	

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	print(Singleton2.player_name)
	if Input.is_action_pressed("backspace"):
		readonly = false
	if get_text().length() > 20 && !Input.is_action_pressed("backspace"):
		readonly = true
		return
	Singleton2.player_name = text
