extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var synced_sprite = $Sprite
onready var sound = $AudioStreamPlayer
onready var area = $Area2D

var collected = false
var destroy_timer = 0.0

func collect(body):
	if !collected && body.name.begins_with("Character") && body.controllable:
		if PlayerSettings.number_of_players == -1:
			sound.play()
		elif PlayerSettings.my_player_index == 0 and body.name == "Character" or PlayerSettings.my_player_index == 1 and body.name == "Character2":
			sound.play()
		collected = true;
		# this shouldn't have to be a thing, but godot is annoying
		synced_sprite.visible = false
		animated_sprite.visible = true
		animated_sprite.playing = true
		destroy_timer = 2
		
func _ready():
	area.connect("body_entered", self, "collect")

func _physics_process(delta):
	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			queue_free()
