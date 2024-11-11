extends Button

signal read_completed

## credits to Pukkah
## https://github.com/Pukkah/HTML5-File-Exchange-for-Godot

onready var level_code_edit: TextEdit = $"%LevelCode"

var js_callback: JavaScriptObject = JavaScript.create_callback(self, "load_handler");
var js_interface: JavaScriptObject;


func _ready():
	if not OS.has_feature("JavaScript"): 
		queue_free()
		return

	_define_js()
	js_interface = JavaScript.get_interface("_HTML5FileExchange");


func _define_js()->void:
	#Define JS script
	JavaScript.eval("""
	var _HTML5FileExchange = {};
	_HTML5FileExchange.upload = function(gd_callback) {
		canceled = true;
		var input = document.createElement('INPUT'); 
		input.setAttribute("type", "file");
		input.setAttribute("accept", ".txt");
		input.click();
		input.addEventListener('change', event => {
			if (event.target.files.length > 0){
				canceled = false;}
			var file = event.target.files[0];
			var reader = new FileReader();
			this.fileType = file.type;
			// var fileName = file.name;
			reader.readAsText(file);
			reader.onloadend = (evt) => { // Since here's it's arrow function, "this" still refers to _HTML5FileExchange
				if (evt.target.readyState == FileReader.DONE) {
					this.result = evt.target.result;
					gd_callback(); // It's hard to retrieve value from callback argument, so it's just for notification
				}
			}
		  });
	}
	""", true)


func load_handler(_args):
	var text_data: String = JavaScript.eval("_HTML5FileExchange.result", true) # interface doesn't work as expected for some reason
	level_code_edit.text = text_data


func open_file_picker():
	js_interface.upload(js_callback);
