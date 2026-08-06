extends PanelContainer


onready var icon = $Icon
onready var glow = $Glow
onready var viewport = $".."


var initial_gradient_colors: PoolColorArray
var initial_gradient_offsets: PoolRealArray
var cur_hue: float = 0

const TOTAL_FRAMES: int = 74
var frames_rendered: int = 0


func _ready():
	var initial_gradient: GradientTexture = icon.material.get_shader_param("gradient")
	initial_gradient_colors = initial_gradient.gradient.colors
	initial_gradient_offsets = initial_gradient.gradient.offsets


func _process(delta):
	if frames_rendered >= TOTAL_FRAMES: return
	
	cur_hue += 1.0 / float(TOTAL_FRAMES)
	
	var cur_gradient_colors: PoolColorArray = initial_gradient_colors
	for i in range(cur_gradient_colors.size()):
		cur_gradient_colors[i] = Color.from_hsv(cur_hue, initial_gradient_colors[i].s, initial_gradient_colors[i].v)
	
	var new_gradient := Gradient.new()
	new_gradient.colors = cur_gradient_colors
	new_gradient.offsets = initial_gradient_offsets
	
	var new_gradient_texture := GradientTexture.new()
	new_gradient_texture.gradient = new_gradient
	
	icon.material.set_shader_param("gradient", new_gradient_texture)
	
	var glow_gradient: Gradient = glow.texture.gradient
	for i in range(glow_gradient.colors.size()):
		glow_gradient.colors[i] = Color.from_hsv(cur_hue, glow_gradient.colors[i].s, glow_gradient.colors[i].v, glow_gradient.colors[i].a)
	
	if frames_rendered != 0:
		var icon_img: Image = viewport.get_texture().get_data()
		icon_img.flip_y()
		icon_img.save_png("res://assets/artwork/discord/icon_frames/icon%s.png" % wrapi(frames_rendered - 9, 0, TOTAL_FRAMES))
	frames_rendered += 1
