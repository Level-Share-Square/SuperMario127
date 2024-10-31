extends AnimationPlayer


export var character_path: NodePath
onready var character: Character = get_node_or_null(character_path)

var is_shown: bool


func _ready():
	if is_instance_valid(character):
		play_backwards("transition")
		character.connect("start_moving", self, "start_moving")
		character.connect("stop_moving", self, "stop_moving")


func start_moving():
	if is_shown: return
	is_shown = true
	play("transition")


func stop_moving():
	if not is_shown: return
	if character.state != null: return
	is_shown = false
	play_backwards("transition")
