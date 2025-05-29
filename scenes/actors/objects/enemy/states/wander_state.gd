extends EnemyPatrolState


onready var wander_timer: Timer = get_node_or_null("%WanderTimer")

export var min_wander_time: float = 3.0
export var max_wander_time: float = 5.0


func _start() -> void:
	._start()
	
	enemy.facing_direction = round(rand_range(0, 1)) * 2 - 1
	var wander_time = rand_range(min_wander_time, max_wander_time)
	var walk_anim_frame_count: float = enemy.sprite.frames.get_frame_count("walk")
	var walk_anim_fps: float = enemy.sprite.frames.get_animation_speed("walk")
	
	wander_timer.start(stepify(wander_time, walk_anim_fps / walk_anim_frame_count))
