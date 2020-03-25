extends Node

export var server : NodePath

onready var server_node = get_node(server)
onready var uuid = uuid_util.v4()

var active = false

var socket

func _process(delta):
	if !server_node.active and Input.is_action_just_pressed("connect_to_game"):
		if active:
			stop_hosting()
		else:
			start_hosting()
	
	if active:
		if socket.get_available_packet_count() > 0:
			var data_string = socket.get_packet().get_string_from_ascii()
			var data = JSON.parse(data_string).result
			if data[0] != uuid:
				if data[1] == "quit":
					stop_hosting()
				elif data[1] == "load_level":
					print_debug("A")
					status_print("Loading level")
					var level_data = LevelData.new()
					level_data.load_in(data[2])
					CurrentLevelData.level_data = level_data
					music.loading = true
					yield(get_tree().create_timer(0.1), "timeout")
					get_tree().reload_current_scene()
				else:
					status_print("Unknown data received: " + data[1])

func start_hosting():
	active = true
	socket = PacketPeerUDP.new()
	if socket.listen(4242, "127.0.0.1") != OK:
		status_print("An error occurred listening on port 4242")
		stop_hosting()
	else:
		status_print("Listening on port 4242 on localhost")
	
	socket.set_dest_address("127.0.0.1", 4242)
	socket.put_packet(JSON.print([uuid, "connection"]).to_ascii())
	
func stop_hosting():
	active = false
	socket.close()
	status_print("Socket closed")
	socket = null

func _exit_tree():
	if active:
		stop_hosting()
		
func status_print(status):
	print("[CLIENT]: ", status)
