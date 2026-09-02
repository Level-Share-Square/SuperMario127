extends NinePatchRect


const TWEEN_IN_TIME: float = 0.25
const TWEEN_OUT_TIME: float = 0.5

export var character_path: NodePath
onready var character: Character = get_node(character_path)

var last_health: int = 8
var tween: SceneTreeTween


func _ready():
	# waiting for things to ready themselves yada yada
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	character.connect("health_changed", self, "health_changed")
	health_changed(character.health)


func health_changed(new_health: int, new_shards: int = -1):
	if new_health < last_health:
		if is_instance_valid(tween):
			tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 1.0, TWEEN_IN_TIME)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate:a", 0.0, TWEEN_OUT_TIME)
	last_health = new_health
