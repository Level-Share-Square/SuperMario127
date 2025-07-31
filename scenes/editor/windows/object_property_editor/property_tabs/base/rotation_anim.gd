extends TextureButton


const TINT_SPEED: float = 0.05
const ROTATE_SPEED: float = 0.1

onready var hover_sound: AudioStreamPlayer = get_owner().get_node("%HoverSound") 
onready var click_sound: AudioStreamPlayer = get_owner().get_node("%ClickSound") 

onready var tween = $Tween
onready var tween_2 = $Tween2
onready var timer = $Timer

export var direction: int = 1

var firing: bool
var fire_countdown: int = 0


func mouse_entered():
	tween.interpolate_property(self, "modulate", modulate, Color.gray, TINT_SPEED)
	tween.start()
	hover_sound.play()


func mouse_exited():
	tween.interpolate_property(self, "modulate", modulate, Color.white, TINT_SPEED)
	tween.start()


func pressed():
	click_sound.play()
	rect_rotation = 10 * direction
	tween_2.interpolate_property(self, "rect_rotation", rect_rotation, 0, 
		ROTATE_SPEED, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween_2.start()


func _process(delta):
	if not firing: return
	fire_countdown -= 1
	if fire_countdown <= 0:
		fire_countdown = 6
		emit_signal("pressed")


func button_down():
	timer.start()


func button_up():
	timer.stop()
	set_firing(false)


func set_firing(new_value: bool):
	firing = new_value
