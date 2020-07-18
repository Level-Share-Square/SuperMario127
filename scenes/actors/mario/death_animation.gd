extends AnimatedSprite

var velocity := Vector2()
var gravity := 0.0
var time_until_fall := 0.0
var anim_playing := false
var falling := false
var rotate_direction := 1
var time_alive := 0.0

var last_downwards := false
onready var fludd_sprite = $Fludd

func _ready():
	var level_area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	gravity = level_area.settings.gravity

func play_anim():
	velocity = Vector2()
	visible = true
	animation = "death"
	anim_playing = true
	time_until_fall = 0.55
	
func _process(_delta):
	fludd_sprite.frame = frame
	fludd_sprite.animation = animation
	
func _physics_process(delta):
	time_alive += delta
	if anim_playing:
		if time_until_fall > 0:
			time_until_fall -= delta
			if time_until_fall < 0:
				time_until_fall = 0
				falling = true
				animation = "deathFall"
				velocity.y = -450
				rotate_direction = -1 if int(time_alive * 10) % 2 == 0 else 1
		
		if falling:
			velocity.y += gravity
			position += velocity * delta
			if velocity.y > 0:
				rotation_degrees += 2.5 * rotate_direction
