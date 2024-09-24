extends TimerBase

onready var progress_bar := $TextureProgress
onready var sprite := $Sprite
export var icon: Texture = null

# these timers are made to read existing properties,
# rather than counting by themselves
var read_node: Node
var read_property: String


func _ready():
	set_icon(icon)


func _physics_process(_delta):
	time = read_node[read_property]
	
	# justt in case the timer is set again right after running out
	if not is_counting and time > 0:
		cancel_time_over()
	
	if is_counting:
		progress_bar.value = time
		
		if time <= 0:
			time = 0
			time_over()


func set_icon(texture: Texture):
	if texture == null: return
	sprite.texture = icon


func set_max_time(new_max: float):
	progress_bar.max_value = new_max
