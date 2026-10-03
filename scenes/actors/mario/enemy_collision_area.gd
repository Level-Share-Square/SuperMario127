class_name CharacterHitbox
extends Area2D


export(NodePath) var character_path

export(NodePath) var normal_shape
export(NodePath) var dive_shape


func _physics_process(_delta):
	if not is_instance_valid(get_node_or_null(dive_shape)):
		return
	
	var character: Character = get_node(character_path)
	
	if is_instance_valid(character.state):
		get_node(normal_shape).disabled = character.state.use_dive_collision
		get_node(dive_shape).disabled = not character.state.use_dive_collision
	else:
		get_node(normal_shape).disabled = false
		get_node(dive_shape).disabled = true


func get_character():
	return get_node_or_null(character_path)
