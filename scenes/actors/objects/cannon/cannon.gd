extends GameObject

var stored_character

const ROTATION_RETURN_TIME = 0.5

export (float) var launch_power = 500
export (float) var min_rotation = 0
export (float) var max_rotation = 90

func _ready():
	set_process(false)
	# warning-ignore:return_value_discarded
	$PipeEnterLogic.connect("pipe_animation_finished", self, "_start_cannon_animation")

#disabled by default until process is enabled, so this can assume the cannon is already in an active state
func _process(delta):
	#if the jump button is pressed, fire the cannon
	if stored_character.inputs[stored_character.input_names.jump][stored_character.input_params.pressed]:
		set_process(false)

		stored_character.invulnerable = false
		stored_character.controllable = true
		stored_character.movable = true
		stored_character.position = $CannonMoveable/SpriteBody/CannonExitPosition.global_position
		stored_character.velocity = Vector2.UP.rotated($CannonMoveable/SpriteBody.rotation) * launch_power

		$Tween.interpolate_property($CannonMoveable/SpriteBody, "rotation", null, 0, ROTATION_RETURN_TIME)	
		$Tween.start()

	#booleans when converting to integer are 0 or 1, so doing right - left means when right is pressed, it'll be 1, when left is pressed it'll be -1, and when both/neither are pressed it'll be 0
	var horizontal_input = int(stored_character.inputs[stored_character.input_names.right][stored_character.input_params.pressed]) - int(stored_character.inputs[stored_character.input_names.left][stored_character.input_params.pressed])

	if horizontal_input != 0:
		$CannonMoveable/SpriteBody.rotation += horizontal_input * delta
		$CannonMoveable/SpriteBody.rotation = clamp($CannonMoveable/SpriteBody.rotation, deg2rad(min_rotation), deg2rad(max_rotation))

func _start_cannon_animation(character):
	stored_character = character 

	$AnimationPlayer.play("cannon_startup")

	$EntranceCollision/CollisionShape2D.disabled = true

func _on_animation_finished(anim_name):
	if anim_name == "cannon_startup":
		stored_character.controllable = true
		$CannonMoveable/SpriteBody/SpriteFuse.visible = true
		set_process(true)
	else:
		$EntranceCollision/CollisionShape2D.disabled = false
		$PipeEnterLogic.is_idle = true

func _on_tween_all_completed():
	$AnimationPlayer.play("cannon_retract")
	$CannonMoveable/SpriteBody/SpriteFuse.visible = false
