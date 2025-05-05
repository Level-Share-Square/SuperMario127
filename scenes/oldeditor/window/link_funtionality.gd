extends RichTextLabel


func _ready():
	connect("meta_clicked", self, "open_link")

func open_link(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at run-time.
	OS.shell_open(str(meta))
