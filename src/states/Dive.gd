extends "res://src/State.gd"

export var divePower: Vector2 = Vector2(1350, 75);

class_name DiveState

func _startCheck(delta):
	return Input.is_action_just_pressed("dive") and !character.isGrounded() and !character.isWalled();

func _start(delta):
	var divePlayer = character.get_node("DiveSoundPlayer");
	character.velocity.x = character.velocity.x - (character.velocity.x - (divePower.x * character.facingDirection)) / 5;
	character.velocity.y += divePower.y;
	character.oldFriction = character.friction;
	character.rotating = true;
	divePlayer.play();

func _update(delta):
	pass;

func _stopCheck(delta):
	return character.isGrounded();
