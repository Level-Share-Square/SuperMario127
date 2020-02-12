extends KinematicBody2D

export var initPos = Vector2(0, 0);
export var velocity = Vector2(0, 0);
var lastVelocity = Vector2(0, 0);
export var gravityScale = 1;
export var facingDirection = 1;

export var moveSpeed = 216.0;
export var acceleration = 7.5;
export var deceleration = 25.0;
export var airAccel = 7.5;
export var friction = 10.5;
export var airFriction = 2.30;

export var jumpPower = 350.0;
var jumpPlaying = true;

export var divePower = Vector2(1350, 75);
var diving = false;
export var canDive = true;
var rotating = false;
var sliding = false;
var diveRecharge = 0;
var oldFriction = 10.5;
var gettingUp = false;
export var getUpPower = 320.0;
var lastAboveRotLimit = false;
var canJump = true;
var canMove = true;

export var wallJumpPower = Vector2(350, 320);
var directionOnWJ = 1;
var wallJumping = false;
var wallJumpTimer = 0.0;
var lastWallDirection = 1;

var jumpBuffer = 0.0;
var ledgeBuffer = 0.0;
var wjBuffer = 0.0;
var wallBuffer = 0.0;

func _physics_process(delta):
	var globalVarsNode = get_node("../GlobalVars");
	var levelSettingsNode = get_node("../LevelSettings");
	
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")");
	
	if globalVarsNode.gameMode != "Editing":
		
		var collisionShape = get_node("CollisionShape2D");
		var sprite = get_node("AnimatedSprite");
		var jumpPlayer = get_node("JumpSoundPlayer");
		var divePlayer = get_node("DiveSoundPlayer");
		
		# Buffers
		if jumpBuffer > 0:
			jumpBuffer -= delta;
			if jumpBuffer < 0:
				jumpBuffer = 0;
		if ledgeBuffer > 0:
			ledgeBuffer -= delta;
			if ledgeBuffer < 0:
				ledgeBuffer = 0;
		if wjBuffer > 0:
			wjBuffer -= delta;
			if wjBuffer < 0:
				wjBuffer = 0;
		if wallBuffer > 0:
			wallBuffer -= delta;
			if wallBuffer < 0:
				wallBuffer = 0;
		if wallJumpTimer > 0:
			wallJumpTimer -= delta;
			if wallJumpTimer < 0:
				wallJumpTimer = 0;
				
		# Gravity
		velocity += globalVarsNode.gravity * Vector2(gravityScale, gravityScale);
		
		# Collision Checks
		var collisionDown;
		var collisionUp;
		var collisionLeft;
		var collisionRight;
		# Down
		if (test_move(self.transform, Vector2(0, 0.1))):
			collisionDown = true;
			velocity.y = 0;
			ledgeBuffer = 0.075;
		# Up
		if (test_move(self.transform, Vector2(0, -0.1))):
			collisionUp = true;
			velocity.y = 10;
		# Left
		if (test_move(self.transform, Vector2(-0.1, 0))):
			collisionLeft = true;
			velocity.x = 0;
		# Right
		if (test_move(self.transform, Vector2(0.1, 0))):
			collisionRight = true;
			velocity.x = 0;
			
		# Movement
		var moveDirection = 0;
		if (Input.is_action_pressed("move_left") && canMove):
			moveDirection = -1;
		elif (Input.is_action_pressed("move_right") && canMove):
			moveDirection = 1;
		if moveDirection != 0:
			if collisionDown:
				if ((velocity.x > 0 && moveDirection == -1) || (velocity.x < 0 && moveDirection == 1)):
					velocity.x += deceleration * moveDirection;
				elif ((velocity.x < moveSpeed && moveDirection == 1) || (velocity.x > -moveSpeed && moveDirection == -1)):
					velocity.x += acceleration * moveDirection;
				elif ((velocity.x > moveSpeed && moveDirection == 1) || (velocity.x < -moveSpeed && moveDirection == -1)):
					velocity.x -= 3.5 * moveDirection;
				facingDirection = moveDirection;
					
				if moveDirection == 1:
					sprite.animation = "movingRight";
				else:
					sprite.animation = "movingLeft";
				if (abs(velocity.x) > moveSpeed):
					sprite.speed_scale = abs(velocity.x) / moveSpeed;
				else:
					sprite.speed_scale = 1;
			else:
				if ((velocity.x < moveSpeed && moveDirection == 1) || (velocity.x > -moveSpeed && moveDirection == -1)):
					velocity.x += airAccel * moveDirection;
				elif ((velocity.x > moveSpeed && moveDirection == 1) || (velocity.x < -moveSpeed && moveDirection == -1)):
					velocity.x -= 0.25 * moveDirection;
					
				if (velocity.x > 0 && moveDirection == 1) or (velocity.x < 0 && moveDirection == -1):
					facingDirection = moveDirection;
		else:
			if (velocity.x > 0):
				if (velocity.x > 15):
					if (collisionDown):
						velocity.x -= friction;				
					else:
						velocity.x -= airFriction;
				else:
					velocity.x = 0;
			elif (velocity.x < 0):
				if (velocity.x < -15):
					if (collisionDown):
						velocity.x += friction;
					else:
						velocity.x += airFriction;
				else:
					velocity.x = 0;
					
			if collisionDown:
				if facingDirection == 1:
					sprite.animation = "idleRight";
				else:
					sprite.animation = "idleLeft";
				sprite.speed_scale = 1;
				
		# Jump
		if Input.is_action_just_pressed("jump") && canJump:
			jumpBuffer = 0.075;
		if jumpBuffer > 0 && ledgeBuffer > 0 && canJump:
			velocity.y = -jumpPower;
			position.y -= 3;
			ledgeBuffer = 0;
			jumpBuffer = 0;
			jumpPlaying = true;
			jumpPlayer.play();
			collisionDown = false;
		if jumpPlaying && velocity.y < 0 && !collisionDown:
			if facingDirection == 1:
				sprite.animation = "jumpRight";
			else:
				sprite.animation = "jumpLeft";
		else:
			jumpPlaying = false;
			if !collisionDown:
				if facingDirection == 1:
					sprite.animation = "fallRight";
				else:
					sprite.animation = "fallLeft";
			
		# Dive
		if Input.is_action_pressed("dive") && !collisionDown && !collisionLeft && !collisionRight && canDive:
			velocity.x = velocity.x - (velocity.x - (divePower.x * facingDirection)) / 5;
			velocity.y += divePower.y;
			canDive = false;
			diving = true;
			oldFriction = friction;
			rotating = true;
			canJump = false;
			divePlayer.play();
		if (diving):
			if (collisionDown):
				friction = 2.25;
				diving = false;
				sliding = true;
				canMove = false;
				canJump = false;
				sprite.rotation_degrees = 0;
				velocity.y = 0;
			else:
				friction = oldFriction;
			if (facingDirection == 1):
				sprite.animation = "diveRight";
			else:
				sprite.animation = "diveLeft";
		if (sliding):
			if (facingDirection == 1):
				sprite.animation = "diveRight";
			else:
				sprite.animation = "diveLeft";
			if (velocity.x < 15 && velocity.x > -15):
				sliding = false;
				rotating = false;
				friction = oldFriction;
				canDive = true;
				canJump = true;
				canMove = true;
				sprite.rotation_degrees = 0;
				if (facingDirection == 1):
					sprite.animation = "idleRight";
				else:
					sprite.animation = "idleLeft";
			elif (Input.is_action_pressed("jump")):
				if (!gettingUp):
					sliding = false;
					rotating = false;
					gettingUp = true;
					diveRecharge = 0.35;
					canJump = true;
					canMove = true;
					friction = oldFriction;
					velocity.y = -getUpPower;
					jumpPlayer.play();
					sprite.rotation_degrees = 0;
					if (facingDirection == 1):
						sprite.animation = "jumpRight";
					else:
						sprite.animation = "jumpLeft";
		if (diveRecharge > 0):
			diveRecharge -= delta;
			if (diveRecharge <= 0):
				diveRecharge = 0;
				gettingUp = false;
				canDive = true;
		if (rotating || sliding):
			var newAngle = ((velocity.y / 7) * facingDirection) + (90 * facingDirection);
			if (velocity.y < globalVarsNode.maxGravityVelocity.y):
				sprite.rotation_degrees = newAngle;
				lastAboveRotLimit = false;
			else:
				if (!lastAboveRotLimit):
					sprite.rotation_degrees = ((globalVarsNode.maxGravityVelocity.y / 7) * facingDirection) + (90 * facingDirection);
				sprite.rotation_degrees += 0.1;
				lastAboveRotLimit = true;
				
		# Wall Jump
		if Input.is_action_just_pressed("jump") && !collisionDown:
			wjBuffer = 0.075;
		if (collisionLeft || collisionRight):
			wallBuffer = 0.1;
			lastWallDirection = 1;
			wallJumping = false;
			if collisionLeft:
				lastWallDirection = -1;
		if !collisionDown && wallBuffer > 0 && wjBuffer > 0 && !jumpPlaying && !diving:
			facingDirection = 1;
			if lastWallDirection == -1:
				facingDirection = -1;
			velocity.x = wallJumpPower.x * -facingDirection;
			velocity.y = -wallJumpPower.y;
			self.position.x -= 2;
			self.position.y -= 2;
			collisionLeft = false;
			collisionRight = false;
			collisionDown = false;
			directionOnWJ = -facingDirection;
			wallJumping = true;
			wallBuffer = 0;
			wjBuffer = 0;
			wallJumpTimer = 0.45;
			jumpPlayer.play();
		if diving:
			wallJumping = false;
		if wallJumping:
			if (directionOnWJ == 1):
				sprite.animation = "jumpRight";
			else:
				sprite.animation = "jumpLeft";
			if (collisionDown):
				wallJumping = false;
		elif (collisionLeft || collisionRight) && !diving && !collisionDown:
			if (collisionRight):
				sprite.animation = "wallSlideRight";
			else:
				sprite.animation = "wallSlideLeft";

		# Move by velocity
		move_and_slide(velocity);
		
		# Boundaries
		if position.y > (levelSettingsNode.levelSize.y * 32) + 128:
			position = initPos;
			velocity = Vector2(0, 0);
		if position.x < 0:
			position.x = 0;
			velocity.x = 0;
		if position.x > levelSettingsNode.levelSize.x * 32:
			position.x = levelSettingsNode.levelSize.x * 32;
			velocity.x = 0;
		lastVelocity = velocity;
