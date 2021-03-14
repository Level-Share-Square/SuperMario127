extends GameObject

var show_behind_layer := false

var exit_timer = 0.0
var exit_pos
var tween_to
var character

var wait_timer = 0.0

export var character_string = "character"

onready var sound = $AudioStreamPlayer

func _ready():
	if mode == 0:
		if character_string != "character" and Singleton.PlayerSettings.number_of_players == 1: return
		if enabled and (Singleton.CheckpointSaved.current_checkpoint_id == -1 or Singleton.CurrentLevelData.level_data.vars.transition_data != []):
			var player = get_tree().get_current_scene()
			character = player.get_node(player[character_string])
			var transition_data = Singleton.CurrentLevelData.level_data.vars.transition_data
			var transition_character_data = Singleton.CurrentLevelData.level_data.vars.transition_character_data
			if transition_data.size() == 0:
				character.position = position
			else:
				var found_pipe = false
				var pipe
				
				yield(get_tree(), "physics_frame")
				for pipe_obj in Singleton.CurrentLevelData.level_data.vars.pipes:
					if pipe_obj[0] == transition_data[1].to_lower():
						pipe = pipe_obj
						found_pipe = true
						break
				
				if found_pipe:
					character.invulnerable = true
					character.movable = false
					character.controllable = false

					character.position = pipe[1].position + Vector2(0, pipe[1].get_bottom_distance())
					yield(get_tree().create_timer(0.5), "timeout")
					if character_string != "character":
						yield(get_tree().create_timer(1.25), "timeout")
					pipe[1].start_exit_anim(character)
				else:
					character.position = position
				Singleton.CurrentLevelData.level_data.vars.transition_data = []
				
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
					
			character.spawn_pos = position
			character.get_node("Spotlight").enabled = false
			character.scale = Vector2(abs(scale.x), scale.y)
			if scale.x < 0:
				character.facing_direction = -character.facing_direction
			character.visible = visible
