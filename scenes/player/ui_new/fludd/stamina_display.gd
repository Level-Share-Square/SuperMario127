extends Control


onready var progress = $Progress

export var character_path: NodePath
onready var character: Character = get_node(character_path)

export var display_offset: Vector2
export var alpha: float
export var fade_speed: float


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
	
	var player_pos: Vector2 = character.get_global_transform_with_canvas().get_origin()
	rect_position = player_pos + display_offset
	modulate.a = lerp(modulate.a, alpha if is_visible else 0, delta * fade_speed)


## for the ui hiding stuff
func _ready():
	Singleton.PhotoMode.connect("photo_mode_changed", self, "toggle_photo_mode")
	toggle_photo_mode()


func toggle_photo_mode():
	visible = not Singleton.PhotoMode.enabled
