extends HTTPRequest


onready var file := File.new()


func update_status():
	if file.file_exists("user://lss_token"):
		file.open("user://lss_token", File.READ)
		
		for i in range(3):
			# first 3 vars arent important
			file.get_var()
		var token: String = file.get_var()
		
		file.close()
		
		
		var header: PoolStringArray = [
			"Authorization: Bearer " + token
		]
		var error: int = request(
			"https://levelsharesquare.com/api/app/intervals/SM127", 
			header, 
			true, 
			HTTPClient.METHOD_POST
		)
		if error != OK:
			printerr("Failed to update LSS status.")


func request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray):
	print("LSS ping complete. Response code: ", response_code)
	
func _physics_process(delta):
	OS.set_window_title("Super Mario 127 (FPS: " + str(Engine.get_frames_per_second()) + ")")
