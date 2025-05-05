extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var limits := Vector2(0, 2)
var options := {
	0: "Face Left",
	1: "Face Right",
	2: "Flip",
}

var value = 1
var last_hovered = false

func _ready():
	var _connect = connect("pressed", self, "pressed")
	if options != null:
		var text: String = options[value]
		if typeof(text) == TYPE_STRING:
			text = text.capitalize()
		text = text

func pressed():
	click_sound.play()
	set_value(value+1)

func set_value(_value: int):
	value = _value
	value = wrapi(value, limits.x, limits.y)
	# Does object have a name for the value?
	if options != null:
		var text: String = options[value]
		if typeof(text) == TYPE_STRING:
			text = text.capitalize()
		text = options[value]
	else:
		# Default to value otherwise
		text = str(value)

func get_value() -> int:
	return value

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
