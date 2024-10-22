extends Button


onready var rate_panel = $"%RatePanel"
onready var fill = $Outline/Fill

var previous_rate: float
var new_rate: float = 0.5


func level_loaded(page_info: LSSLevelPage):
	previous_rate = page_info.has_rated
	fill.value = previous_rate


func _gui_input(event):
	if event is InputEventMouseMotion:
		var relative_pos = (event.position.x / rect_size.x) * 5
		relative_pos = stepify(relative_pos + 0.125, 0.5)
		relative_pos = clamp(relative_pos, 0.5, 5)
		
		new_rate = relative_pos
		fill.value = relative_pos


func mouse_exited():
	fill.value = previous_rate


func _pressed():
	if new_rate == previous_rate: return
	rate_panel.submit_rating(new_rate)
	previous_rate = new_rate
