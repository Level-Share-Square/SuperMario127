extends Area2D


onready var enemy: EnemyBase = get_owner()
onready var sprite: AnimatedSprite = get_parent()

export var enabled: bool
export var connected: bool


func initialize() -> void:
	if not enabled or enemy.enabled:
		queue_free()
		return


func area_entered(area: Area2D) -> void:
	if connected: return
	connected = true
	
	var dialogue_trigger: GameObject = area.get_parent().get_parent()
	dialogue_trigger.connect("change_emote", self, "start_talking")
	dialogue_trigger.connect("start_talking", self, "start_talking", [1, 0])
	dialogue_trigger.connect("stop_talking", self, "stop_talking")


func start_talking(expression: int, _action: int) -> void:
	if expression == 1:
		sprite.play("speak")
	else:
		sprite.play("idle")


func stop_talking() -> void:
	sprite.play("idle")
