extends GameObject

var _timer = null
#onready var size = $Testsponge
#onready var area = $Area2D
#onready var coll = $StaticBody2D

var water_drain_speed = 5
var water_in_sponge = 0
var max_water = 50
var player_in_area = false
var body

#applies the timer
func _ready():
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops

#the opposite of body_entered and stops the timer
func _on_Area2D_body_exited(body1):
	if player_in_area == true and body1.name.begins_with("Character") and !body1.dead:
		player_in_area = false
		_timer.stop()
		print("Body exited")

#checks if the player has entered the area2D and starts the timer
func _on_Area2D_body_entered(body1):
	if player_in_area == false and body1.name.begins_with("Character") and !body1.dead:
		print("Body Entered")
		player_in_area = true
		body = body1
		_timer.start()
		print("Timer started")

#triggers everytime the timer has ran
func _on_Timer_timeout():
	if player_in_area == true and body.name.begins_with("Character") and !body.dead and body.fuel != 0:
		if water_in_sponge < max_water:
			body.fuel -= water_drain_speed
			water_in_sponge += water_drain_speed
			#size.scale += Vector2(0.25,0.25)
			#area.scale += Vector2(0.25,0.25)
			#coll.scale += Vector2(0.25,0.25)
