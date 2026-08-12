extends Control


export var force_show: bool

export var character_path: NodePath
onready var character: Character = get_node(character_path)


func _ready():
	LastInputDevice.connect("input_type_changed", self, "update_visibility")
	update_visibility(LastInputDevice.last_input_type)


func update_visibility(input_type: int):
	visible = (input_type == LastInputDevice.InputType.Touch)
	if force_show:
		visible = true


## can't check for paused any other way sadly
func _process(delta):
	modulate.a = lerp(modulate.a, 0 if get_tree().paused else 1, delta * 8)
