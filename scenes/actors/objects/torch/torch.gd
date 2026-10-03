extends GameObject

const DEFAULT_BACKGROUND_COLOR: Color = Color(0.545098, 0.545098, 0.545098)

var force_tint: bool = false
var color = Color(1, 1, 0)
const light_color = Color(0.87, 0.65, 0.05)
export(Array, Texture) var palette_textures

onready var light : Light2D = $Light2D
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var sprite2 : AnimatedSprite = $AnimatedSprite/RecolorableSprite


#func _set_properties():
#	savable_properties = ["color"]
#	editable_properties = ["color"]


func _register_properties(): 
	register_property(5, "color", color, true)
	register_property(6, "force_tint", force_tint, true)


func _ready():
	if mode == 1:
		# warning-ignore: unused_variable
		connect("property_changed", self, "update_property")
		get_tree().current_scene.get_shared_node().connect("layer_edited", self, "layer_edited")
	
	update_light_layer()
	update()
	if not force_tint: sprite.modulate = math_util.scalar_color_division(1, level_layer_ref.get_ref().modulate)
	else: sprite.modulate = Color.white

func update_property(key: String, value):
	match key:
		"visible", "enabled":
			update()
		"force_tint":
			if not force_tint: sprite.modulate = math_util.scalar_color_division(1, level_layer_ref.get_ref().modulate)
			else: sprite.modulate = Color.white

func layer_edited(uuid, property, value):
	if uuid == level_layer_ref.get_ref().layer_data.layer_metadata.layer_uuid:
		if property == "layer_tint":
			if not force_tint: sprite.modulate = math_util.scalar_color_division(1, value)
			else: sprite.modulate = Color.white
			
	
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


func update():
	sprite.visible = visible
	light.visible = enabled
	visible = true


func update_light_layer():
	light.range_z_max = level_layer_ref.get_ref().z_index
	light.range_z_min = level_layer_ref.get_ref().z_index
