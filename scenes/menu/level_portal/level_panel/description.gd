extends PanelContainer


const TRANSITION_DURATION: float = 0.7


export var max_size: int = 136
export var expand_text: String = "Read more..."
export var collapse_text: String = "Collapse"


onready var rich_text_label = $VBoxContainer/MarginContainer/RichTextLabel
onready var button = $VBoxContainer/Button
onready var tween = $Tween


var true_size: int
var expanded: bool


func set_description(new_text: String):
	var text: String = "[center]" + new_text + "[/center]"
	
	button.visible = false
	expanded = false
	button.text = expand_text
	
	rich_text_label.fit_content_height = true
	rich_text_label.rect_min_size.y = 0
	rich_text_label.rect_size.y = 0
	rich_text_label.bbcode_text = text
	
	visible = (not new_text == "")
	if new_text != "":
		rich_text_label.connect("resized", self, "label_resized", [], CONNECT_ONESHOT)

func label_resized():
	if rich_text_label.rect_size.y > max_size:
		true_size = rich_text_label.rect_size.y
		button.visible = true
		
		rich_text_label.fit_content_height = false
		rich_text_label.rect_min_size.y = max_size
		rich_text_label.rect_size.y = max_size



func toggle_expand():
	if expanded:
		collapse_description()
	else:
		expand_description()
		
	expanded = not expanded
	button.text = collapse_text if expanded else expand_text


func expand_description():
	tween.stop_all()
	tween.interpolate_property(
		rich_text_label,
		"rect_min_size:y",
		rich_text_label.rect_min_size.y,
		true_size,
		TRANSITION_DURATION,
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT
	)
	tween.start()


func collapse_description():
	tween.stop_all()
	tween.interpolate_property(
		rich_text_label,
		"rect_min_size:y",
		rich_text_label.rect_min_size.y,
		max_size,
		TRANSITION_DURATION,
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT
	)
	tween.start()
