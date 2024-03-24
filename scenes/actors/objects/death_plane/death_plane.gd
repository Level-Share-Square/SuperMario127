extends GameObject

onready var area = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var camera_stopper = $CameraStopper
onready var camera_stop_shape = $CameraStopper/CollisionShape2D
onready var sprite = $Sprite


export var parts := 1
export var stops_camera := true
export var vertical := false

var last_parts := 1

func _set_properties():
	savable_properties = ["parts", "stops_camera", "vertical"]
	editable_properties = ["parts", "stops_camera", "vertical"]

func _set_property_values():
	set_property("parts", parts, 1)
	set_property("stops_camera", stops_camera)
	set_property("vertical", vertical)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts, true)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts, true)

	
func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "kill")
		sprite.visible = false
		camera_stopper.monitorable = stops_camera
	else:
		var _connect2 = connect("property_changed", self, "update_property")
	update_parts()
	
func update_property(key, value):
	match(key):
		"parts":
			update_parts()
		"vertical":
			if vertical:
				sprite.rect_size.x = 32
				sprite.rect_position.x = -16
				collision_shape.shape.extents.x = 16
				camera_stop_shape.shape.extents.x = 52
			else:
				sprite.rect_size.y = 32
				sprite.rect_position.y = -16
				collision_shape.shape.extents.y = 16
				camera_stop_shape.shape.extents.y = 52
			update_parts()
		"rotation_degrees":
			rotation_degrees = 0
			
func update_parts():
	if vertical:
		sprite.rect_size.y = parts * 32
		sprite.rect_position.y = (-16 * parts)
		collision_shape.shape.extents.y = 16 * parts
		camera_stop_shape.shape.extents.y = collision_shape.shape.extents.y + 26
	else:
		sprite.rect_size.x = parts * 32
		sprite.rect_position.x = (-16 * parts)
		collision_shape.shape.extents.x = 16 * parts
		camera_stop_shape.shape.extents.x = collision_shape.shape.extents.x + 26
		
func kill(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable and !(body.powerup != null and body.powerup.id == "Vanish"):
		body.sprite.visible = false
		body.kill("fall")
		enabled = false
				
	
	

			

