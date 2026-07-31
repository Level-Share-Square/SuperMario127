extends GameObject

onready var area = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var camera_stopper = $CameraStopper
onready var camera_stop_shape = $CameraStopper/CollisionShape2D
onready var sprite = $Sprite


var parts := 1
export var stops_camera := true
export var vertical := false

var last_parts := 1

#func _set_properties():
#	savable_properties = ["parts", "stops_camera", "vertical"]
#	editable_properties = ["parts", "stops_camera", "vertical"]

func _register_properties():
	register_property(4, "parts", parts)
	register_property(5, "stops_camera", stops_camera)
	register_property(6, "vertical", vertical)
	
func _unhandled_input(event: InputEvent) -> void:
	parts_input_handler(event,self)

	
func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "kill")
		sprite.visible = false
		camera_stopper.monitorable = stops_camera
	else:
		var _connect2 = connect("property_changed", self, "update_property")
		camera_stopper.visible = stops_camera
	if parts < 1:
		parts = 1
	update_property("vertical", vertical)
	camera_stopper.set_size(camera_stop_shape.shape.extents)
	
	
func update_property(key, value):
	match(key):
		"parts":
			if value < 1:
				parts = 1
				return
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
		"stops_camera":
			camera_stopper.visible = stops_camera
			
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
	if is_enabled_and_on_ground() and body.name.begins_with("Character") and !body.dead and body.controllable:
		if stops_camera:
			body.sprite.visible = false
			body.kill("fall")
		else:
			body.kill("green_demon")
		enabled = false
		
		
				
func _process(delta):
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)
			

