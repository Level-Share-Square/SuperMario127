extends GameObject

var show_behind_layer := false

var exit_timer = 0.0
var exit_pos
var tween_to
var character
var transition_data
var transition_character_data


var wait_timer = 0.0

export var character_string = "character"

onready var sound = $AudioStreamPlayer

# ==================================================================================
# | As best as I can tell, this is a singleton called in whenever an area changes. |
# | All remote teleporters in an area are listening to this singleton to see       |
# | which teleporter Mario should exit from. When the time comes, this script      |
# | should carry over all of Mario's data from the last area, and pass an instance |
# | of Mario over to the teleporter he's supposed to exit from.                    |
# ==================================================================================

func _ready():
	if mode == 0:
		if character_string != "character" and Singleton.PlayerSettings.number_of_players == 1: return
		if enabled and (Singleton.CheckpointSaved.current_checkpoint_id == -1 or Singleton.CurrentLevelData.level_data.vars.transition_data != []):
			var player = get_tree().get_current_scene()
			character = player.get_node(player[character_string])
			transition_data = Singleton.CurrentLevelData.level_data.vars.transition_data
			transition_character_data = Singleton.CurrentLevelData.level_data.vars.transition_character_data
			if character_string != "character":
				transition_character_data = Singleton.CurrentLevelData.level_data.vars.transition_character_data_2
				
			if transition_data.size() == 0:
				character.position = position
			else:
				var found_obj = false
				var obj
				
				yield(get_tree(), "physics_frame")
				for tp_obj in Singleton.CurrentLevelData.level_data.vars.teleporters:
					if tp_obj[0] == transition_data[1].to_lower():
						obj = tp_obj
						found_obj = true
						break
				
				if found_obj:
					character.invulnerable = true
					character.movable = false
					character.controllable = false
					
					match transition_data[0]:
						"pipe", "door", "area_transition":
							exit_teleport(obj)
							pass
						_:
							push_error("Remote teleport unsuccessful! %s has an invalid object type!" % transition_data[1])
							character.position = position
							Singleton.CurrentLevelData.level_data.vars.transition_data = []
							pass
					
				else:
					character.position = position
					character.toggle_movement(true)
				_cleanup()


func exit_teleport(obj : Array):
	#print(obj[1].object_type)
	if transition_data[2] == true: #Remember, true = remote, false = local
		if obj[1].teleportation_mode != true:
			character.position = position
			character.toggle_movement(true)
			_cleanup()
			return
		character.position = obj[1].position
		character.sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)
		if obj[1].object_type == "pipe":
			character.position = obj[1].position + Vector2(0, obj[1].get_bottom_distance())
		if obj[1].object_type == "area_transition":
			obj[1].is_idle = false
			if transition_character_data.size() >= 7 and obj[1].stops_camera:	
				var helper = transition_character_data.back()
				character.camera.global_position = helper.find_camera_position(obj[1].vertical, character.global_position, character.camera.base_size, obj[1].parts * 32)
				character.camera.last_position = character.camera.global_position
				character.camera.auto_move = false
			else:
				character.state = character.get_state_node("FallState")
		yield(get_tree().create_timer(0.5), "timeout")
		if character_string != "character":
			yield(get_tree().create_timer(1.25), "timeout")
		obj[1].start_exit_anim(character)

		if transition_character_data.size() > 0:
			character.health = transition_character_data[0]
			character.health_shards = transition_character_data[1]
			if transition_character_data[2] != null:
				character.set_nozzle(transition_character_data[2])
			character.fuel = transition_character_data[3]
			if transition_character_data[4][0] != null:
				character.set_powerup(character.get_powerup_node(transition_character_data[4][0]), transition_character_data[4][2])
				character.powerup.time_left = transition_character_data[4][1]
			get_tree().get_current_scene().switch_timer = transition_character_data[5]
		_cleanup()

func _cleanup():
	Singleton.CurrentLevelData.level_data.vars.transition_data = []

	character.spawn_pos = position
	character.get_node("Spotlight").enabled = false
	character.scale = Vector2(abs(scale.x), scale.y)
	if scale.x < 0:
		character.facing_direction = -character.facing_direction
	character.visible = visible
