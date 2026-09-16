extends Particles2D

onready var character : Character
onready var particle_material : ParticlesMaterial = process_material

func _ready():
	if get_owner() is Character:
		character = get_owner()

func _process(delta: float) -> void:
	particle_material.emission_box_extents.x = character.velocity.length() * delta
