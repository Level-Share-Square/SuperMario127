class_name BGPaletteButton
extends TextureRect


var fg_modulate: Color
var fg_tex: Texture
var bg_tex: Texture

onready var foreground_texture: TextureRect = $"%Foreground"


func _ready():
	texture = bg_tex
	foreground_texture.texture = fg_tex
	foreground_texture.modulate = fg_modulate


func setup_button(fg_texture: Texture, bg_resource: SkyResource):
	bg_tex = bg_resource.texture
	fg_tex = fg_texture
	fg_modulate = bg_resource.parallax_modulate


func _on_mouse_entered():
	modulate = Color(0.7, 0.7, 1.2)


func _on_mouse_exited():
	modulate = Color.white
