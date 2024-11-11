extends HBoxContainer


export var new_rate_text: String
export var change_rate_text: String

onready var account_info = $"%AccountInfo"
onready var http_account = $"%HTTPAccount"

onready var rate_submitting = $"%RateSubmitting"
onready var label = $Label

var level_id: String


func level_loaded(page_info: LSSLevelPage) -> void:
	visible = account_info.logged_in
	level_id = page_info.level_id
	label.text = change_rate_text if page_info.has_rated > 0 else new_rate_text


func submit_rating(new_rate: float) -> void:
	if not account_info.logged_in: return
	
	visible = false
	rate_submitting.visible = true
	label.text = change_rate_text
	
	http_account.submit_rating(level_id, new_rate)


func rating_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	visible = true
	rate_submitting.visible = false
