extends EnemyState


onready var animation_player = $"%AnimationPlayer"
onready var death_particles = $"%DeathParticles"
onready var timer = $"%Timer"


func _start() -> void:
	animation_player.play("die")
	enemy.sprite.hide()
	for particle in death_particles.get_children():
		particle.emitting = true
	
	timer.stop()
	timer.start(1)
	timer.connect("timeout", enemy, "queue_free")
