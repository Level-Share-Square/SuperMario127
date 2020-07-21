extends GameObject

onready var area = $Area2D
onready var move_to_point = $MoveToPoint
onready var exit_to_point = $ExitToPoint
onready var sound = $AudioStreamPlayer
var activated = false

var area_id := 0
var exit_from : Vector2
var exit_animation := true

var character = null
var entering_pipe = false

var align_timer = 0.0
var enter_timer = 0.0

var align_pos
var enter_pos

func _set_properties():
	savable_properties = ["area_id", "exit_from", "exit_animation"]
	editable_properties = ["area_id", "exit_from", "exit_animation"]
	
func _set_property_values():
	set_property("area_id", area_id, true)
	set_property("exit_from", exit_from, true)
	set_property("exit_animation", exit_animation, true)
	
func enter(body):
	if CurrentLevelData.level_data.areas.size() > area_id and enabled and !activated and body.name.begins_with("Character"):
		character = body
		
func exit(body):
	if body == character and !entering_pipe:
		character = null

func _physics_process(delta):
	rotation_degrees = 0
	scale = Vector2(1, 1)
	if character != null:
		var directional_condition
		directional_condition = character.inputs[10][0] and character.is_grounded() and character.move_direction == 0
		
		if enabled and !entering_pipe and directional_condition:
			character.controllable = false
			character.invulnerable = true
			character.movable = false
			#character.rotation_degrees = rotation_degrees
			if character.facing_direction == 1:
				character.sprite.animation = "pipeRight"
			else:
				character.sprite.animation = "pipeLeft"
			entering_pipe = true
			align_timer = 0.65
			align_pos = Vector2(position.x + move_to_point.position.x, character.position.y)
	
		if align_timer > 0:
			character.position = character.position.linear_interpolate(align_pos, delta * 5)
			align_timer -= delta
			if align_timer <= 0:
				align_timer = 0
				enter_timer = 1.5
				enter_pos = Vector2(position.x + move_to_point.position.x, position.y + move_to_point.position.y)
				sound.play()
				
		if enter_timer > 0:
			character.position = character.position.linear_interpolate(enter_pos, delta * 1)
			enter_timer -= delta
			if enter_timer <= 0.525 and character.visible or !visible:
				if visible:
					character.visible = false
				CurrentLevelData.level_data.vars.transition_data = [
					"pipe", 
					exit_from, 
					exit_animation, 
					Vector2(exit_from.x + move_to_point.position.x, exit_from.y + move_to_point.position.y), 
					exit_from.y + exit_to_point.position.y
				]
			if enter_timer <= 0:
				enter_timer = 0
				entering_pipe = false
				character.switch_areas(area_id, 0.5)

func _ready():
	if mode != 1:
		var _connect = area.connect("body_entered", self, "enter")
		var _connect2 = area.connect("body_exited", self, "exit")
		
func on_place():
	set_property("exit_from", position, true)
