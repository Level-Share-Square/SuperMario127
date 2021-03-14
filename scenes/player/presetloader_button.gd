extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var controls_options = get_parent().get_parent()
onready var player_selector_manager = controls_options.get_node("PlayerSelectors")

var last_hovered
	
func _pressed():
	click_sound.play()
	
	var selector = get_parent().get_node("Selector")
	Singleton.PlayerSettings.keybindings[player_selector_manager.player_id()] = ControlPresets.presets[selector.text].duplicate(true)
	
	controls_options.currentButton = null
	
	# Not a super elegant solution, but rn it doesn't really matter
	Singleton.PlayerSettings.legacy_wing_cap = (selector.text == "Legacy")
	controls_options.get_node("Legacy Wing Cap").get_node("ToggleButton").update_text()

	for children in get_parent().get_parent().get_children():
		if !(children.get_name() in controls_options.ignore_children):
			var button : Button = children.get_node("KeyButton")
			
			button.text = ControlUtil.get_formatted_string(button.id, player_selector_manager.player_id())
			SettingsSaver.override_keybindings(button.id, player_selector_manager.player_id())
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
