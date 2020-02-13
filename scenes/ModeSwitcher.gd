extends Node2D

func switchModes():
	var globalVarsNode = get_node("../GlobalVars");
	if globalVarsNode.gameMode == "Testing":
		switchToEditing();
	else:
		switchToTesting();
	
func switchToEditing():
	var globalVarsNode = get_node("../GlobalVars");
	var character = get_node("../Character");
	var ghostTile = get_node("../GhostTile");
	var grid = get_node("../Grid/ParallaxLayer");
	var banner = get_node("../UI/Banner");
	
	globalVarsNode.gameMode = "Editing";
	character.hide();
	ghostTile.show();
	grid.show();
	banner.show();

func switchToTesting():
	var globalVarsNode = get_node("../GlobalVars");
	var character = get_node("../Character");
	var ghostTile = get_node("../GhostTile");
	var grid = get_node("../Grid/ParallaxLayer");
	var banner = get_node("../UI/Banner");
	
	globalVarsNode.gameMode = "Testing";
	character.show();
	ghostTile.hide();
	grid.hide();
	banner.hide();

func _ready():
	var globalVarsNode = get_node("../GlobalVars");
	if globalVarsNode.gameMode == "Editing":
		switchToEditing();
	else:
		switchToTesting();

func _process(delta):
	if Input.is_action_just_pressed("switch_modes"):
		switchModes();
