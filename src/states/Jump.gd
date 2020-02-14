extends State

class_name JumpState

export var jumpPower: float = 350;
var jumpBuffer = 0;
var jumpPlaying = false;
onready var sprite = character.get_node("AnimatedSprite");
onready var jumpPlayer = character.get_node("JumpSoundPlayer");

func _startCheck(delta):
	return character.isGrounded() and jumpBuffer > 0;

func _start(delta):
	character.velocity.y = -jumpPower;
	character.position.y -= 3;
	jumpBuffer = 0;
	jumpPlaying = true;
	jumpPlayer.play();

func _update(delta):
	if jumpPlaying && character.velocity.y < 0 && !character.isGrounded():
		if character.facingDirection == 1:
			sprite.animation = "jumpRight";
		else:
			sprite.animation = "jumpLeft";
	else:
		jumpPlaying = false;

func _stopCheck(delta):
	return character.isGrounded();

func _generalUpdate(delta):
	if jumpBuffer > 0:
		jumpBuffer -= delta;
		if jumpBuffer < 0:
			jumpBuffer = 0;
	if Input.is_action_just_pressed("jump"):
		jumpBuffer = 0.075
