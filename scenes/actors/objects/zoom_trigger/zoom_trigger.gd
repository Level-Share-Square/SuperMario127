extends GameObject

onready var area = $Area2D
onready var area_shape = $Area2D/CollisionShape2D
onready var sprite = $Sprite

var target_zoom : float = 1.5
var pan_offset : Vector2 = Vector2.ZERO
var zoom_time : float = 1.0
var parts := 1


func _register_properties():
	register_property(4, "target_zoom", target_zoom)
	register_property(5, "zoom_time", zoom_time)
	register_property(6, "parts", parts)


func _unhandled_input(event: InputEvent) -> void:
	parts_input_handler(event,self)


func update_property(_key, _value):
	update_parts()
	
func _object_ready():
	._object_ready()
	sprite.visible = not is_on_ground_layer()


func update_parts():
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)
	
	sprite.rect_size.y = parts * 32
	sprite.rect_position.y = (-16 * parts)
	area_shape.shape.extents.y = 16 * parts


func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "_body_entered")
		sprite.visible = false
	
	if parts < 1:
		parts = 1
	
	update_parts()


func _body_entered(body):
	if is_enabled_and_on_ground() and body.name.begins_with("Character"):
		#print("set tween")
		if !is_equal_approx(body.camera.zoom.x, target_zoom):
			body.camera.set_zoom_tween(Vector2(target_zoom, target_zoom), zoom_time, true)


func _process(delta):
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)
