extends EnemyStopState


onready var idle_timer: Timer = get_node_or_null("%IdleTimer")

export var min_idle_time: float = 3.0
export var max_idle_time: float = 5.0


func _start() -> void:
	if not enemy.is_on_floor():
		enemy.sprite.play("fall")
	else:
		enemy.sprite.play("idle")
		
		start_idle_timer()



func _update(delta: float) -> void:
	._update(delta)
	
	if enemy.is_on_floor():
		if enemy.sprite.animation == "fall":
			start_idle_timer()
		
		enemy.sprite.play("idle")
	else:
		enemy.sprite.play("fall")


func start_idle_timer():
	var idle_time = rand_range(min_idle_time, max_idle_time)
	
	idle_timer.start(idle_time)
