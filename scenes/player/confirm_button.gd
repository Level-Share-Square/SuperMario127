extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

export var num_of_players : NodePath
export var player1_char : NodePath
export var player2_char : NodePath

var character_node
var last_hovered

func _ready():
	if "mode" in get_tree().get_current_scene():
		character_node = owner.owner.get_node(owner.owner.character)

func _pressed():
	click_sound.play()
	SettingsSaver.save()
	Singleton.PlayerSettings.number_of_players = get_node(num_of_players).value
	Singleton.PlayerSettings.player1_character = get_node(player1_char).value
	Singleton.PlayerSettings.player2_character = get_node(player2_char).value
	
	if "mode" in get_tree().get_current_scene():
		character_node.dead = false
		character_node.kill("reload")
	else:
		disabled = true
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
	
	var settings_match = (
		Singleton.PlayerSettings.number_of_players == get_node(num_of_players).value and
		Singleton.PlayerSettings.player1_character == get_node(player1_char).value and
		Singleton.PlayerSettings.player2_character == get_node(player2_char).value
	)
	
	if Singleton.PlayerSettings.other_player_id != -1 or settings_match:
		disabled = true
	else:
		disabled = false
