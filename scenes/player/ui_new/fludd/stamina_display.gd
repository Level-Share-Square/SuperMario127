extends Control


onready var progress = $Progress

export var character_path: NodePath
onready var character: Character = get_node(character_path)

export var camera_path: NodePath
onready var camera: Camera2D = get_node(camera_path)

export var display_offset: Vector2
export var alpha: float
export var fade_speed: float

export var viewport_offset: Vector2


func _physics_process(delta):
	if not is_instance_valid(character): return
	
	var is_visible: bool = true
	
	var nozzle: Nozzle = character.nozzle
	if is_instance_valid(nozzle): 
		progress.material.set_shader_param("value", nozzle.stamina_value)
		if not nozzle.display_stamina: 
			is_visible = false
	else:
		is_visible = false
	
	var player_pos: Vector2 = character.global_position
	var camera_pos: Vector2 = camera.get_camera_screen_center()
	rect_position = (player_pos - camera_pos) + display_offset + viewport_offset
	modulate.a = lerp(modulate.a, alpha if is_visible else 0, delta * fade_speed)


func player_removed():
	viewport_offset = Vector2(384, 216)


## for the ui hiding stuff
func _ready():
	Singleton.PhotoMode.connect("photo_mode_changed", self, "toggle_photo_mode")
	toggle_photo_mode()


func toggle_photo_mode():
	visible = not Singleton.PhotoMode.enabled
