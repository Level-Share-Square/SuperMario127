extends GameObject

onready var area = $Area2D
onready var area_shape = $Area2D/CollisionShape2D
onready var sprite = $Sprite

var target_zoom : float = 1.5
var pan_offset : Vector2 = Vector2.ZERO
var zoom_time : float = 1.0
var parts := 1

func _set_properties():
	savable_properties = ["target_zoom", "zoom_time", "parts"]
	editable_properties = ["target_zoom", "zoom_time", "parts"]
	
func _set_property_values():
	set_property("target_zoom", target_zoom)
	set_property("zoom_time", zoom_time, true, "Zoom Time")
	set_property("parts", parts)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts, true)
			update_parts()
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts, true)
			update_parts()
			
func update_parts():
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
	if enabled and body.name.begins_with("Character"): #and !body.camera.zoom_tween.is_active():
		#print("set tween")
		if !is_equal_approx(body.camera.zoom.x, target_zoom):
			body.camera.set_zoom_tween(Vector2(target_zoom, target_zoom), zoom_time, true)

#		body.camera.set_pan_tween(position+pan_offset, zoom_time, false)

