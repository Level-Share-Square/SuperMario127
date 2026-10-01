extends Decoration


onready var sprite = $Sprite
onready var top_height = 48
onready var part_height = 32

export var parts := 2


func _register_properties():
	register_property(4, "parts", parts, true)

func _register_property_info():
	set_property_info("parts", PropertyInfo.new("Amount of parts on this object.", 1, 1, INF, ["", ""], ["", ""], true, "Parts"))


func _ready():
	var _connect = connect("property_changed", self, "update_property")
	update_property("parts", parts)


func update_property(key: String, value):
	.update_property(key, value)
	if key == "parts":
		sprite.rect_size.y = top_height + (part_height * parts)
		sprite.rect_position.y = -sprite.rect_size.y + 4
		editor_rect = Rect2(sprite.rect_position, sprite.rect_size)


func _input(event):
	parts_input_handler(event, self)


func update_parts():
	update_property("parts", parts)
