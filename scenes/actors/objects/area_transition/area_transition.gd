extends TeleportObject


onready var area = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var camera_stopper = $CameraStopper
onready var camera_stop_shape = $CameraStopper/CollisionShape2D
onready var sprite = $Sprite

export var parts := 1
export var stops_camera := true
export var vertical := false

var teleport_enabled := true

func _set_properties() -> void:
	savable_properties = ["area_id", "destination_tag", "teleportation_mode", "parts", "stops_camera", "vertical"]
	editable_properties = ["area_id", "destination_tag", "teleportation_mode", "parts", "stops_camera", "vertical"]
	
func _set_property_values() -> void:

	set_property("area_id", area_id)
	set_property("destination_tag", destination_tag)
	set_property("teleportation_mode", teleportation_mode, true, "Teleport Mode")
	set_bool_alias("teleportation_mode", "Remote", "Local")
	set_property("parts", parts)
	set_property("stops_camera", stops_camera)
	set_property("vertical", vertical)
	
	
func _init():
	teleportation_mode = false
	object_type = "area_transition"
	
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
	
func _ready() -> void:
	.ready() #calls parent class "TeleportObject"
	var append_tag
	if destination_tag != "default_teleporter" || destination_tag != null:
		append_tag = destination_tag.to_lower()
	Singleton.CurrentLevelData.level_data.vars.teleporters.append([append_tag, self])
	
	if mode != 1:
		var _connect = area.connect("body_entered", self, "body_entered")
		var _connect2 = area.connect("body_exited", self, "body_exited")
		sprite.visible = false
		camera_stopper.monitorable = stops_camera
	else:
		var _connect2 = connect("property_changed", self, "update_property")
		
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
		
func body_entered(body):
	if enabled and body.name.begins_with("Character") and !body.dead and body.controllable and teleport_enabled:
		print("teleporting")
		body.toggle_movement(false)
		change_areas(body, true)
		
func body_exited(body):
	if enabled and body.name.begins_with("Character") and !body.dead:
		teleport_enabled = true
		
func start_exit_anim(character):
	print("exit anim")
	print(character.global_position)
	# to prevent teleport loop
	teleport_enabled = false;
	character.toggle_movement(true)
#	character.velocity = Singleton.CurrentLevelData.level_data.vars.transition_data[3]
#	character.show()
#	character.sprite.animation = "pipeRight"
#	character.sprite.playing = true
#	character.sprite.frame = 2
	reset_sprite(character)
	Singleton.CurrentLevelData.level_data.vars.transition_data = []
	
func reset_sprite(character : Character): #This is here in case Mario came from a door to a pipe
	character.z_index = -1
	character.sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	character.sprite.scale = Vector2(1.0, 1.0)
	character.sprite.position = Vector2.ZERO
