class_name MusicDownloader
extends Reference


const TEMP_SUFFIX: String = ".temp"


signal request_completed
signal request_progress(percent)
onready var thread


func download(url : String, file_path : String = "user://downloaded_file"):
	thread = Thread.new()
	thread.start(self, "req", [url, file_path])
	

func req(arguments):
	return
	
	var percent_loaded = 0

	var url = arguments[0]
	var file_path = arguments[1]
	
	var http = HTTPClient.new()
	var file = File.new()
	# Regex to process the url
	var re = RegEx.new()
	re.compile("(https:\\/\\/[^\\/]*)(.*)")

	if not re.search_all(url): # Checks if the url is valid
		print("[ERROR] Invalid url")
		return
	
	
	
	var server = re.search(url).get_string(1)
	print("Connecting to: ", server)
	
	url = re.search(url).get_string(2)


	# Connection to host
	http.connect_to_host(server, -1, true)

	#Poll until ice cream
	
	while http.get_status() == HTTPClient.STATUS_RESOLVING or http.get_status() == HTTPClient.STATUS_CONNECTING:
		http.poll()
	
	if http.get_status() == HTTPClient.STATUS_CONNECTED:
		print("Connection established") # If the connection is successful continue

	else:
		print("[ERROR] Connection failed: ", http.get_status()) # Else return from the function
		return

	# Setup headers
	var headers = [
		"User-Agent: Mozilla/5.0",
		"Accept: */*"
	]


	# Make the request
	http.request(HTTPClient.METHOD_GET, url, headers)

	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling until the request is going on
		http.poll()
	

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED)

	
	var response_headers = http.get_response_headers_as_dictionary()
	

#	file.open("user://header.json", File.WRITE)
#	file.store_string(JSON.print(response_headers))
#	file.close()


	if http.get_response_code() == 200: # If the request was successful
		
		file.open(file_path + TEMP_SUFFIX, File.WRITE)
		file.close()
		file.open(file_path + TEMP_SUFFIX, File.READ_WRITE)
	
		while http.get_status() == HTTPClient.STATUS_BODY:
			
			http.poll()
			file.store_buffer(http.read_response_body_chunk())

			if percent_loaded < file.get_len()*100 / http.get_response_body_length():
				percent_loaded = file.get_len()*100 / http.get_response_body_length()
				emit_signal("request_progress", percent_loaded)
				
		file.close()
		saved_levels_util.move_file(file_path + TEMP_SUFFIX, file_path)
		

	elif http.get_response_code() == 302:
		for i in response_headers: response_headers[i.capitalize()] = response_headers[i]
		req([response_headers["Location"], file_path])
		return

	else:
		print("[ERROR] Request not successful: ", http.get_response_code())
		return

	emit_signal("request_completed")
	return
