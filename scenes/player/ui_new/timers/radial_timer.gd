extends TimerBase

onready var progress_bar := $TextureProgress
onready var sprite := $Sprite

export var icon: Texture = null


func _ready():
	set_icon(icon)


func _physics_process(delta):
	count(delta)


func _update_time_display(display_time: float):
	progress_bar.value = display_time


func set_icon(texture: Texture):
	if texture == null: return
	sprite.texture = icon


func set_max_time(new_max: float):
	progress_bar.max_value = new_max
