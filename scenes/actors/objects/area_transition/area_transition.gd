class_name AreaTransition
extends Teleporter


onready var sprite = $Sprite
onready var area2d : Area2D = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var camera_stopper = $CameraStopper
onready var camera_stop_shape = $CameraStopper/CollisionShape2D

var force_fadeout: bool = false
var vertical: bool = true
var parts: int = 1
var stops_camera: bool = true
var is_idle: bool = true
var entering: bool = false


### PROPERTIES
func _set_properties() -> void:
	savable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path", "vertical", "parts", "stops_camera"]
	editable_properties = ["target_area", "tag", "teleport_mode", "max_pan_distance", "level_path", "vertical", "parts", "stops_camera"]


func _set_property_values() -> void:
	set_property("target_area", target_area)
	set_property("tag", tag)
	set_property("teleport_mode", teleport_mode, true)
	set_property_menu("teleport_mode", ["option", 3, 0, ["Location", "Area", "Level"]])
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("max_pan_distance", max_pan_distance)
	set_property("level_path", level_path)

	set_property("vertical", vertical)
	set_property("parts", parts)
	set_property("stops_camera", stops_camera)


### AREA TRANSITION STUFF
func _ready():
	._ready()
	
	if mode == 1:
		var _connect2 = connect("property_changed", self, "update_property")
		sprite.visible = true
	else:
		sprite.visible = false
	
	update_property("parts", parts)
	update_property("vertical", vertical)
	camera_stopper.set_size(camera_stop_shape.shape.extents)
	camera_stopper.monitorable = stops_camera
	camera_stopper.visible = stops_camera
	
	# waits to connect to stop frame 1 teleport bugs
	yield(get_tree().create_timer(1.0), "timeout")
	$Area2D.connect("body_entered", self, "body_entered")
	$Area2D.connect("body_exited", self, "body_exited")

func _unhandled_input(event: InputEvent) -> void:
	parts_input_handler(event,self)

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


### AREA2D STUFF
func body_entered(body) -> void:
	if not body is Character or not body.movable or body.dead: return
	if not enabled: return
	if not is_idle: return
	if entering: return
	
	start_entrance_animation(body)

func body_exited(body) -> void:
	if body is Character:
		entering = false


### ANIMATION
func start_entrance_animation(character: Character) -> void:
	is_idle = false
	entering = true
	character.camera.set_zoom_tween(Vector2(1, 1), 0.5)
	
	if teleport_mode == TeleportMode.Location:
		Singleton.CurrentLevelData.level_data.vars.area_transition_helper = AreaTransitionHelper.new(
			character.velocity, 
			character.state, 
			character.facing_direction, 
			to_local(character.position), 
			self.vertical
		)
	
	var sprite_rotation: float = character.sprite.rotation
	.start_entrance_animation(character)
	character.sprite.rotation = sprite_rotation
	
	begin_warp(character)


func start_exit_animation(character: Character) -> void:
	is_idle = false
	entering = false
	
	var helper: AreaTransitionHelper = Singleton.CurrentLevelData.level_data.vars.area_transition_helper
	finish_exit_animation(character)
	
	character.toggle_movement(false)
	character.show()
	
	if is_instance_valid(helper):
		character.velocity = helper.velocity
		character.state = helper.state
		character.facing_direction = helper.facing_direction
		character.position = global_position + helper.find_exit_offset(vertical, parts * 32)
	else:
		character.position = global_position
	character.reset_physics_interpolation()
	
	yield(get_tree().create_timer(0.1), "timeout")
	is_idle = true
	
	character.toggle_movement(true)
