extends TextureButton

export var editor : NodePath
onready var bounds_control = $"../../../../BoundsControl"

export var tool_index := 0
export var normal_tex : StreamTexture
export var hover_tex : StreamTexture
export var selected_tex : StreamTexture

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered = false

func _pressed():
	bounds_control.visible = !bounds_control.visible
	click_sound.play()
		
func _process(_delta):
	var hovered = is_hovered()
	
	if bounds_control.visible:
		texture_normal = selected_tex
		texture_hover = selected_tex
	else:
		texture_normal = normal_tex
		texture_hover = hover_tex
		if hovered and !last_hovered:
			hover_sound.play()
		
	last_hovered = hovered
