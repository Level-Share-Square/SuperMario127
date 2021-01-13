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
		if character_string != "character" and PlayerSettings.number_of_players == 1: return
		if enabled and (CheckpointSaved.current_checkpoint_id == -1 or CurrentLevelData.level_data.vars.transition_data != []):
			var player = get_tree().get_current_scene()
			character = player.get_node(player[character_string])
			var transition_data = CurrentLevelData.level_data.vars.transition_data
			if transition_data.size() == 0:
				character.position = position
			else:
				character.controllable = false
				yield(get_tree(), "physics_frame")
				for pipe in CurrentLevelData.level_data.vars.pipes:
					if pipe[0] == transition_data[1].to_lower():
						character.position = pipe[1].position + Vector2(0, pipe[1].get_bottom_distance())
						yield(get_tree().create_timer(1.0), "timeout")
						if character_string != "character":
							yield(get_tree().create_timer(1.25), "timeout")
						pipe[1].start_exit_anim(character)
				CurrentLevelData.level_data.vars.transition_data = []
					
			character.spawn_pos = position
			character.get_node("Spotlight").enabled = false
			character.scale = Vector2(abs(scale.x), scale.y)
			if scale.x < 0:
				character.facing_direction = -character.facing_direction
			character.visible = visible
