extends Node2D

onready var globalVarsNode = get_node("../GlobalVars");
onready var character = get_node("../Character");
onready var ghostTile = get_node("../GhostTile");
onready var grid = get_node("../Grid/ParallaxLayer");
onready var banner = get_node("../UI/Banner");
onready var music = get_node("../Music");

func switchModes():
	if globalVarsNode.gameMode == "Testing":
		switchToEditing();
	else:
		switchToTesting();
	
func switchToEditing():
	globalVarsNode.gameMode = "Editing";
	character.hide();
	ghostTile.show();
	grid.show();
	banner.show();
	music.stop();

func switchToTesting():
	globalVarsNode.gameMode = "Testing";
	character.show();
	ghostTile.hide();
	grid.hide();
	banner.hide();
	music.play();
	
	if Input.is_key_pressed(KEY_SHIFT):
		character.position = get_global_mouse_position();

func _ready():
	if globalVarsNode.gameMode == "Editing":
		switchToEditing();
	else:
		switchToTesting();

func _process(delta):
	if Input.is_action_just_pressed("switch_modes"):
		switchModes();
