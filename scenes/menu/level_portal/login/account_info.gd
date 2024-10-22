class_name AccountInfo
extends Node


signal login
signal logout

var logged_in: bool

var id: String
var username: String
var icon_url: String
var token: String

var store_vars: Array = [
	"id", "username", "icon_url", "token"
]


func save_info():
	if not logged_in: return
	
	var file := File.new()
	file.open("user://lss_token", File.WRITE)
	
	for variable in store_vars:
		file.store_var(self[variable])
	
	file.close()


func load_info():
	if logged_in: return
	
	var file := File.new()
	if file.file_exists("user://lss_token"):
		file.open("user://lss_token", File.READ)
		
		for variable in store_vars:
			self[variable] = file.get_var()
		login()
		
		file.close()


func delete_info():
	if level_list_util.file_exists("user://lss_token"):
		level_list_util.delete_file("user://lss_token")



func login():
	logged_in = true
	emit_signal("login")

func logout():
	delete_info()
	logged_in = false
	emit_signal("logout")
