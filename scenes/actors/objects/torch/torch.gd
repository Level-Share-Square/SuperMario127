extends GameObject

var is_background = true
export(Array, Texture) var palette_textures

onready var light : Light2D = $Light2D
var sinx : float
export var steps = 1
func _set_properties():
	savable_properties = ["is_background"]
	editable_properties = ["is_background"]

func _set_property_values(): 
	set_property("is_background", is_background, true)
	
func _ready():
	if(!visible):
		visible = true
		$AnimatedSprite.visible = false
	

func _process(delta):
	
	if is_background:
		z_index = -2 if !is_preview else 0
		light.range_z_min = -10
		light.range_z_max = -10
	else:
		z_index = 11 if !is_preview else 0
		light.range_z_min = 0
		light.range_z_max = 10
		light.energy = 1
	#control light flicker
	light.texture_scale = (round(steps*max(-abs(tan(sin(sinx/steps)))+1, -(abs(tan(sin((sinx/steps)+(1/2)*PI)))-1))-steps)) /6 + 1
	sinx += 0.12

