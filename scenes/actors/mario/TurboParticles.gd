extends Particles2D

onready var character : Character = $"../../"
onready var particle_material : ParticlesMaterial = process_material


func _process(delta: float) -> void:
	particle_material.emission_box_extents.x = character.velocity.length_squared() * delta
