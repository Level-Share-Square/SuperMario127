extends Node

onready var http_request = $HTTPRequest

var internet: bool = false


func start_internet_check():
	# google should always be up and running, right? :)
	http_request.request("https://google.com/")


func request_completed(result, response_code, headers, body):
	internet = false
	if result == 0:
		internet = true
	
	print("Internet connection available: " + str(internet).capitalize())
