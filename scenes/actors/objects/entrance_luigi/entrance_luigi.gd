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
		if enabled and CheckpointSaved.current_checkpoint_id == -1:
			var player = get_tree().get_current_scene()
			character = player.get_node(player.character2)
			var transition_data = CurrentLevelData.level_data.vars.transition_data
			if transition_data.size() == 0:
				character.position = position
			else:
				if transition_data[2] == false:
					character.position = transition_data[1]
				else:
					character.position = transition_data[3]
					tween_to = Vector2(character.position.x, transition_data[4])
					character.controllable = false
					character.invulnerable = true
					character.movable = false
					character.visible = false
					if character.facing_direction == 1:
						character.sprite.animation = "pipeRight"
					else:
						character.sprite.animation = "pipeLeft"
					wait_timer = 2.35
					
			character.spawn_pos = position
			character.get_node("Spotlight").enabled = false
			character.scale = Vector2(abs(scale.x), scale.y)
			if scale.x < 0:
				character.facing_direction = -character.facing_direction
			character.visible = visible

func _physics_process(delta):
	if is_instance_valid(character):
		if wait_timer > 0:
			wait_timer -= delta
			character.visible = false
			if wait_timer <= 0:
				wait_timer = 0
				exit_timer = 0.85
				sound.play()
				
		if exit_timer > 0:
			character.position = character.position.linear_interpolate(tween_to, delta * 5)
			exit_timer -= delta
			if exit_timer <= 0.825:
				character.visible = true
			else:
				character.visible = false
			if exit_timer <= 0.15 and character.sprite.animation != "pipeExitRight" and character.sprite.animation != "pipeExitLeft":
				if character.facing_direction == 1:
					character.sprite.animation = "pipeExitRight"
				else:
					character.sprite.animation = "pipeExitLeft"
			if exit_timer <= 0:
				exit_timer = 0
				character.controllable = true
				character.invulnerable = false
				character.movable = true
				character.velocity = Vector2()
