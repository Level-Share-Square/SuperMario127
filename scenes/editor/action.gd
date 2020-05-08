class_name Action

var type := "none"
var data = []

func reverse(shared_node):
	if type == "place_tile":
		for info in data:
			shared_node.set_tile(info[0], info[1], info[2][0], info[2][1])

func execute(shared_node):
	if type == "place_tile":
		for info in data:
			shared_node.set_tile(info[0], info[1], info[3][0], info[3][1])
