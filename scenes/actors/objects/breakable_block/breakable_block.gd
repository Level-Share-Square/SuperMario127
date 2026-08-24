extends BoxBase


onready var outline = $"%Outline"

export(Array, StreamTexture) var inner_textures: Array
export(Array, StreamTexture) var outer_textures: Array
export(Array, StreamTexture) var particle_textures: Array


func _ready():
	._ready()
	update_property("palette", palette)

func update_property(key: String, value):
	.update_property(key, value)
	if key == "palette":
		sprite.texture = inner_textures[value]
		outline.texture = outer_textures[value]
		break_particles.texture = particle_textures[value]
