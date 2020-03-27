extends Node

var network
var connected_type = "None"
		
func start_server():
	network = NetworkedMultiplayerENet.new()
	network.create_server(4242, 2)
	get_tree().set_network_peer(network)
	get_tree().multiplayer.connect("network_peer_connected", self, "_peer_connected")
	get_tree().multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")
	print("Hosting!")
	connected_type = "Server"
	
func start_client(ip):
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, 4242)
	get_tree().set_network_peer(network)
	get_tree().multiplayer.connect("network_peer_connected", self, "_peer_connected")
	get_tree().multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")
	print("Searching...")
	connected_type = "Client"
	
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
	PlayerSettings.other_player_id = -1
	PlayerSettings.my_player_index = 0

func _packet_recieved(id, packet_ascii):
	var packet = JSON.parse(packet_ascii.get_string_from_ascii()).result
	if packet[0] == "load level":
		var level_data = LevelData.new()
		level_data.load_in(packet[1])
		CurrentLevelData.level_data = level_data
		music.loading = true
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().reload_current_scene()
		get_tree().multiplayer.send_bytes(JSON.print(["level loaded"]).to_ascii())
		get_tree().paused = false
	elif packet[0] == "level loaded":
		get_tree().reload_current_scene()
		get_tree().paused = false
	elif packet[0] == "reload":
		get_tree().get_current_scene().get_node(get_tree().get_current_scene().character).kill("reload")
		
func disconnect_from_peers():
	get_tree().multiplayer.set_network_peer(null)
	connected_type = "None"
	PlayerSettings.other_player_id = -1
	PlayerSettings.my_player_index = 0
