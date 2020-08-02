extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var binding_manager = get_parent().get_parent()

export var index : int

var last_hovered

func _ready():
	var device_info_label = get_parent().get_node("DeviceInfoLabel")
	
	if index != PlayerSettings.keybindings[binding_manager.id].size():
		text = ControlUtil.get_formatted_string_by_index(binding_manager.id, index)
		device_info_label.text = ControlUtil.get_device_info(binding_manager.id, index)
	else:
		device_info_label.text = "Add new binding"
	
	var deleteButton : Button = get_parent().get_node("DeleteButton")
	
	if index != 0 && index != PlayerSettings.keybindings[binding_manager.id].size():
		deleteButton.visible = true
	
	if index != 0:
		deleteButton.connect("pressed", self, "deleteButtonPressed")

func _pressed():
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
	PlayerSettings.keybindings[binding_manager.id].remove(index)
	SettingsSaver.override_keybindings(binding_manager.id)
	for children in binding_manager.get_children():
		if children == get_parent():
			children.queue_free()
			break
