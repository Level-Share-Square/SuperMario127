extends Node

var network
var connected_type = "None"

func _input(event):
	if event.is_action_pressed("host_game") and connected_type == "None":
		start_server()
		connected_type = "Server"
	if event.is_action_pressed("connect_to_game") and connected_type == "None":
		start_client()
		connected_type = "Client"
		
func start_server():
	network = NetworkedMultiplayerENet.new()
	network.create_server(4242, 2)
	get_tree().set_network_peer(network)
	get_tree().multiplayer.connect("network_peer_connected", self, "_peer_connected")
	get_tree().multiplayer.connect("network_peer_packet", self, "packet_recieved")
	print("Hosting!")
	
func start_client():
	network = NetworkedMultiplayerENet.new()
	network.create_client(PlayerSettings.connect_to_ip, 4242)
	get_tree().set_network_peer(network)
	get_tree().multiplayer.connect("network_peer_connected", self, "_peer_connected")
	get_tree().multiplayer.connect("network_peer_packet", self, "packet_recieved")
	print("Searching...")
	
func _peer_connected(id):
	PlayerSettings.other_player_id = id
	if connected_type == "Server":
		PlayerSettings.my_player_index = 0
		print("Player connected! ID: " + str(id))
		get_tree().multiplayer.send_bytes(JSON.print(["load level", CurrentLevelData.level_data.get_encoded_level_data()]).to_ascii())
	else:
		PlayerSettings.my_player_index = 1

func _peer_disconnected(id):
	print("Player disconnected. ID: " + str(id))
	connected_type = "None"

func packet_recieved(id, packet_ascii):
	var packet = JSON.parse(packet_ascii.get_string_from_ascii()).result
	if packet[0] == "load level":
		var level_data = LevelData.new()
		level_data.load_in(packet[1])
		CurrentLevelData.level_data = level_data
		music.loading = true
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().reload_current_scene()
		get_tree().multiplayer.send_bytes(JSON.print(["level loaded"]).to_ascii())
	if packet[0] == "level loaded":
		get_tree().reload_current_scene()
