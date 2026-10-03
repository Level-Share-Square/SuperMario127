extends AudioStreamPlayer

## bit hacky but eh, this basically forwards play calls to a sound node above this scene
## so that deletion does not affect sound playback

onready var owner_parent = owner.get_parent()
onready var owner_sound = owner_parent.get_node("%" + name)

func play(position: float = 0) -> void:
	owner_sound.play(position)
