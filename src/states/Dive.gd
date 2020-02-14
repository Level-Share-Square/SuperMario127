extends "res://src/State.gd"

class_name DiveState

export var divePower: Vector2 = Vector2(1350, 75);
var sliding = false;
onready var divePlayer = character.get_node("DiveSoundPlayer");
onready var sprite = character.get_node("AnimatedSprite");

func _startCheck(delta):
	return Input.is_action_just_pressed("dive") and !character.isGrounded() and !character.isWalled();

func _start(delta):
	character.velocity.x = character.velocity.x - (character.velocity.x - (divePower.x * character.facingDirection)) / 5;
	character.velocity.y += divePower.y;
	character.oldFriction = character.friction;
	character.rotating = true;
	divePlayer.play();

func _update(delta):
	if (character.isGrounded()):
		character.friction = 2.25;
		sliding = true;
		sprite.rotation_degrees = 0;
		character.velocity.y = 0;
	else:
		character.friction = character.oldFriction;
	if (character.facingDirection == 1):
		sprite.animation = "diveRight";
	else:
		sprite.animation = "diveLeft";

func _stopCheck(delta):
	return false;
