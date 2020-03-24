extends HBoxContainer

onready var viewport_container1 = $ViewportContainer
onready var viewport_container2 = $ViewportContainer2

onready var viewport1 = $ViewportContainer/Viewport
onready var viewport2 = $ViewportContainer2/Viewport

onready var player1 = $ViewportContainer/Viewport/World/Character
onready var player2 = $ViewportContainer/Viewport/World/Character2

export var divider_path : NodePath
onready var divider = get_node(divider_path)

var number_of_players = 2

func _ready():
	viewport2.world_2d = viewport1.world_2d
	player1.number_of_players = number_of_players
	player2.number_of_players = number_of_players
	if number_of_players == 1:
		player2.dead = true
		player2.visible = false
		player2.queue_free()
		viewport_container2.queue_free()
		viewport_container1.rect_size.x = 768
		viewport1.size.x = 768
		divider.visible = false

func _process(delta):
	if number_of_players == 2:
		if player2.dead and number_of_players:
			number_of_players = 1
			player1.number_of_players = number_of_players
			viewport_container2.visible = false
			viewport_container1.rect_size.x = 768
			viewport1.size.x = 768
			divider.visible = false
		elif player1.dead and number_of_players:
			number_of_players = 1
			player2.number_of_players = number_of_players
			viewport_container1.visible = false
			viewport_container2.rect_size.x = 768
			viewport2.size.x = 768
			divider.visible = false
