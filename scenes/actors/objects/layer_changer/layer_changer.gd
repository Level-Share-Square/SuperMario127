extends GameObject

onready var area = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var camera_stopper = $CameraStopper
onready var camera_stop_shape = $CameraStopper/CollisionShape2D
onready var sprite = $Sprite


var parts := 1
export var stops_camera := false
export var vertical := false

var layer_uuid: String = ""
var parallax_distance: float = 0
var tint := Color(0.545098, 0.545098, 0.545098)
var opacity: float = 1
var is_visible: bool = true
var move_to_index: int = -1
var one_time: bool = false

var last_parts := 1
var used: bool = false

func _register_properties():
	register_property(4, "parts", parts)
	register_property(5, "stops_camera", stops_camera)
	register_property(6, "vertical", vertical)
	register_property(7, "layer_uuid", layer_uuid)
	register_property(8, "parallax_distance", parallax_distance)
	set_property_info("parallax_distance", PropertyInfo.new(
		"How far away this layer will be. Negative values are closer.",
		1,
		-1000,
		1000
	))
	register_property(9, "tint", tint)
	register_property(10, "opacity", opacity)
	set_property_info("opacity", PropertyInfo.new(
		"How transparent this layer will be.",
		0.05,
		0,
		1
	))
	register_property(11, "is_visible", is_visible)
	register_property(12, "move_to_index", move_to_index)
	register_property(13, "one_time", one_time)
	set_property_override("layer_uuid", PropertyTab.OverrideTypes.DROPDOWN, [self, "get_layer_args"])
	
func get_layer_args() -> Dictionary:
	var args: Dictionary = {}
	
	var shared = get_tree().current_scene.get_shared_node()
	for layer in shared.layers:
		args[layer] = shared.get_layer(layer).layer_data.layer_metadata.layer_name
	return args

func _unhandled_input(event: InputEvent) -> void:
	parts_input_handler(event,self)

func _object_ready():
	._object_ready()
	if !is_enabled_and_on_ground():
		sprite.visible = true
		camera_stopper.set_size(Vector2.ZERO)
		camera_stopper.monitorable = false
		camera_stopper.visible = false
	
func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "update_layer")
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
		
func update_layer(body):
	if is_enabled_and_on_ground() and body.name.begins_with("Character") and !body.dead and body.controllable:
		if used and one_time: return
		
		var player = get_tree().current_scene
		var shared = player.get_shared_node()
		var character = player.get_node(player.character)
		if !shared.get_layer(layer_uuid): return
		if move_to_index < 0 or move_to_index > shared.layers.size() - 1: move_to_index = -1
		
		var layer_state := LayerState.new(
			move_to_index,
			parallax_distance,
			tint,
			opacity,
			is_visible
		)
		
		shared.load_layer_states({layer_uuid: layer_state})
		CurrentLevelData.vars.layer_states[CurrentLevelData.area_id][layer_uuid] = layer_state
	
		character.update_layer_info()
		
		used = true
		
				
func _process(delta):
	if parts <= 0:
		parts = 1
		set_property("parts", parts, true)
			

