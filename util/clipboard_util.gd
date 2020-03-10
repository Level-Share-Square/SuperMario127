class_name clipboard_util

static func copy(string : String):
	if OS.has_feature("JavaScript"):
		JavaScript.eval("""
			const el = document.createElement('textarea')
			el.value = '""" + string + """'
			document.body.appendChild(el)
			el.select()
			document.execCommand('copy')
			document.body.removeChild(el)
		""", true)
	else:
		OS.clipboard = string
