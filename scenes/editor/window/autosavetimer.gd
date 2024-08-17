extends Control

onready var label = $TimerLabel
onready var selector = $Selector

var times = ["Never", "5 Minutes", "15 Minutes", "30 Minutes", "1 Hour"]


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	if !file.file_exists("user://autosaves/settings.file"):
		Singleton2.autosave_timer = 108000
		save_timer()
		Singleton2.reset_time()
	else:
		file.open("user://autosaves/settings.file", File.READ)
		var timer = file.get_var()
		file.close()
		Singleton2.autosave_timer = timer
		Singleton2.reset_time()
	for i in times:
		selector.add_item(i)
	selector.connect("item_selected", self, "item_selected")
		
func _physics_process(delta):
	if $"../LevelName".visible == false:
		rect_position = Vector2(-107, -165)
	else:
		rect_position = Vector2(-300, -127)
	match Singleton2.autosave_timer:
		9223372036854775807:
			selector._select_int(0)
		18000:
			selector._select_int(1)
		54000:
			selector._select_int(2)
		108000:
			selector._select_int(3)
		216000:
			selector._select_int(4)
			
func item_selected(index):
	match selector.selected:
		0:
			Singleton2.autosave_timer = 9223372036854775807
		1:
			Singleton2.autosave_timer = 18000
		2:
			Singleton2.autosave_timer = 54000
		3:
			Singleton2.autosave_timer = 108000
		4:
			Singleton2.autosave_timer = 216000
	save_timer()
	Singleton2.reset_time()
			
func save_timer():
	var file = File.new()
	file.open("user://autosaves/settings.file", File.WRITE)
	file.store_var(Singleton2.autosave_timer)
	file.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
