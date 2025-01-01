class_name ParticlesCollection
extends Node2D

var particle_nodes : Array = []

func _ready():
	for child in get_children():
		if (child is Particles2D) or (child is CPUParticles2D):
			particle_nodes.append(child)
#			print(child)

func set_particles_emitting(value : bool):
	for particle in particle_nodes:
		particle.emitting = value

func set_particles_color(color : Color):
	for particle in particle_nodes:
		if particle is Particles2D:
			particle.process_material.color = color
		if particle is CPUParticles2D:
			particle.color = color
