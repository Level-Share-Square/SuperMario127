extends GameObject

export var custom_preview_position = Vector2(70, 170)
onready var sprite = $Sprite

var time := 0.0
var last_position : Vector2

func _ready():
	Singleton.CurrentLevelData.enemies_instanced += 1
	time = (Singleton.CurrentLevelData.enemies_instanced * 100) / 3
	sprite.animation = "butterfly" + str((Singleton.CurrentLevelData.enemies_instanced % 6) + 1)
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		sprite.z_index = 0
	
func _physics_process(delta):
	if mode != 1 and enabled:
		time += delta
		sprite.position.x = sin(time * 2) * 30
		sprite.position.y = sin(time * 1) * 30
		sprite.flip_h = true if sign(sprite.position.x - last_position.x) == -1 else false
		last_position = sprite.position
