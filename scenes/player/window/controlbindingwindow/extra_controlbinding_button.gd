extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var binding_manager = get_parent().get_parent()

export var index : int

var last_hovered

func _ready():
	var device_info_label = get_parent().get_node("DeviceInfoLabel")
	
	if index != Singleton.PlayerSettings.keybindings[binding_manager.player_selector_manager.player_id()][binding_manager.id].size():
		text = ControlUtil.get_formatted_string_by_index(binding_manager.id, binding_manager.player_selector_manager.player_id(), index)
		device_info_label.text = ControlUtil.get_device_info(binding_manager.id, binding_manager.player_selector_manager.player_id(), index)
	else:
		device_info_label.text = "Add new binding"
	
	var deleteButton : Button = get_parent().get_node("DeleteButton")
	
	if index != 0 && index != Singleton.PlayerSettings.keybindings[binding_manager.player_selector_manager.player_id()][binding_manager.id].size():
		deleteButton.visible = true
	
	if index != 0:
		# warning-ignore: return_value_discarded
		deleteButton.connect("pressed", self, "deleteButtonPressed")

func _gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT:
		if binding_manager.currentButton != null:
			binding_manager.currentButton.text = binding_manager.oldText
			binding_manager.currentButton = null
			return
		
		binding_manager.currentButton = self
		binding_manager.oldText = text
		text = "Wait..."
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
	
func deleteButtonPressed():
	Singleton.PlayerSettings.keybindings[binding_manager.player_selector_manager.player_id()][binding_manager.id].remove(index)
	SettingsSaver.override_keybindings(binding_manager.id, binding_manager.player_selector_manager.player_id())
	for children in binding_manager.get_children():
		if children == get_parent():
			children.queue_free()
			break
			
	var temp_index = 0
	for children in binding_manager.get_children():
		if children == get_parent():
			continue
		children.get_node("KeyButton").index = temp_index
		temp_index+=1
