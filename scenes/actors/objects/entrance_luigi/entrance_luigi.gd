extends GameObject

var show_behind_layer := false

var exit_timer = 0.0
var exit_pos
var tween_to
var character

var wait_timer = 0.0

onready var sound = $AudioStreamPlayer

func _ready():
	if mode == 0:
		if enabled and Singleton.CheckpointSaved.current_checkpoint_id == -1:
			var player = get_tree().get_current_scene()
			character = player.get_node(player.character2)
			var transition_data = Singleton.CurrentLevelData.level_data.vars.transition_data
			if transition_data.size() == 0:
				character.position = position
			else:
				yield(get_tree(), "physics_frame")
				for pipe in Singleton.CurrentLevelData.level_data.vars.pipes:
					if pipe[0] == transition_data[1].to_lower():
						pipe[1].start_exit_anim(character)
					
			character.spawn_pos = position
			character.get_node("Spotlight").enabled = false
			character.scale = Vector2(abs(scale.x), scale.y)
			if scale.x < 0:
				character.facing_direction = -character.facing_direction
			character.visible = visible
