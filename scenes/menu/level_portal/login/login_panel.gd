extends PanelContainer


onready var http_login = $"%HTTPAccount"
onready var email_input := $"%Email"
onready var password_input := $"%Password"

onready var wrong_pass = $"%WrongPass"
onready var timer = $Timer

onready var login_contents = $"%LoginContents"
onready var please_wait = $"%PleaseWait"

onready var login_screen = $"%Login"


func login():
	var email: String = email_input.text
	var password: String = password_input.text
	
	http_login.login(email, password)
	
	login_contents.hide()
	please_wait.show()


func request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	login_contents.show()
	please_wait.hide()
	
	if response_code != 200:
		timer.start(5)
		wrong_pass.show()
		return
	
	email_input.text = ""
	password_input.text = ""
	login_screen.transition("LevelList")


func timeout():
	wrong_pass.hide()
