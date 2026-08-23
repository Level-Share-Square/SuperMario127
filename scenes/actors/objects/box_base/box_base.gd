extends GameObject
class_name BoxBase

enum Sides {TOP = 1, BOTTOM = 2, LEFT = 4, RIGHT = 8}

export(int, FLAGS, "Top", "Bottom", "Left", "Right") var breakable_sides = 15
export var breakable_states: PoolStringArray
export var breakable_objects: PoolStringArray

onready var box = $"%Box"
onready var box_collision = $"%BoxCollision"
onready var editor_collision = $"%EditorCollision"
onready var player_detector = $"%PlayerDetector"
onready var break_animation = $"%BreakAnimation"

var broken: bool = false

func try_break(body: Node2D) -> void:
	if broken: return
	
	var hit_flag: int = 0
	
	if body is Character:
		if (breakable_states) and (not body.state): return
		if (breakable_states) and (body.state) and (not body.state.name in breakable_states): return
		box.add_collision_exception_with(body)
		
	var distance: Vector2 = body.global_position - global_position
	
	if abs(distance.x) > abs(distance.y):
		hit_flag = Sides.LEFT if distance.x < 0 else Sides.RIGHT
	else:
		hit_flag = Sides.TOP if distance.y < 0 else Sides.BOTTOM
	
	if breakable_sides & hit_flag != 0:
		break_box()
	elif body is Character and body in box.get_collision_exceptions():
		box.remove_collision_exception_with(body)

func break_box() -> void:
	broken = true
	box_collision.queue_free()
	break_animation.play("break")

func _physics_process(_delta):
	if broken: return
	for body in player_detector.get_overlapping_bodies():
		if body is Character:
			try_break(body)
