extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

export var num_of_players : NodePath
export var player1_char : NodePath
export var player2_char : NodePath

export var character_node_path : NodePath
onready var character_node = get_node(character_node_path)

var last_hovered

func _pressed():
	click_sound.play()
	PlayerSettings.number_of_players = get_node(num_of_players).value
	PlayerSettings.player1_character = get_node(player1_char).value
	PlayerSettings.player2_character = get_node(player2_char).value
	character_node.dead = false
	character_node.kill("reload")
	
func _process(delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
	if PlayerSettings.other_player_id != -1:
		disabled = true
	else:
		disabled = false
