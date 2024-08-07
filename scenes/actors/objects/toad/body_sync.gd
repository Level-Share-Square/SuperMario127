extends AnimatedSprite

onready var coat = $Coat

export var head_path: NodePath
onready var head: AnimatedSprite = get_node(head_path)
export var head_offsets: Dictionary

func _ready():
	play("running")
	coat.play("running")

func _process(delta):
	if not is_instance_valid(head): return
	
	head.position = head_offsets[animation][frame]
	
	coat.animation = animation
	coat.frame = frame
