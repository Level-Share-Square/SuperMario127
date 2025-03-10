extends GameObject

var is_background = false
var color = Color(1, 1, 0)
const light_color = Color(0.87, 0.65, 0.05)
export(Array, Texture) var palette_textures


onready var light : Light2D = $Light2D
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var sprite2 : AnimatedSprite = $AnimatedSprite/RecolorableSprite

func _set_properties():
	savable_properties = ["is_background", "color"]
	editable_properties = ["color"]

func _set_property_values(): 
	set_property("is_background", is_background, true)
	set_property("color", color, true)
	
func _ready():
	if(!visible):
		visible = true
		$AnimatedSprite.visible = false
		
	if is_background:
		layer = 1
		update_layer()
		is_background = false
		
	if mode == 1:
		# warning-ignore: unused_variable
		connect("property_changed", self, "property_changed")
		
	update_light_layer()

			
func property_changed(key: String, value):
	if key == "layer":
		update_light_layer()

func _process(delta):
	sprite2.set_frame(sprite.get_frame())
	

		
	if color == Color(1, 1, 0):
		sprite.self_modulate = Color(1, 1, 1)
		sprite2.visible = false
		light.color = light_color
	else:
		var color_0 = color
		var color_1 = color
		

		color_0.s /= 1.5
		color_0.v *= 3
		
		color_1.s /= 2
		
		sprite2.self_modulate = color_0
		sprite2.visible = true
		
		light.color = color
	
func update_light_layer():
	match(layer):
		0:
			light.range_z_min = -11
			light.range_z_max = -10
		1:
			light.range_z_min = -10
			light.range_z_max = -10
		2:
			light.range_z_min = -1
			light.range_z_max = 0
		3:
			light.range_z_min = 9
			light.range_z_max = 10	

