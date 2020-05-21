extends Node

var network
var connected_type = "None"
		
func start_server():
	network = NetworkedMultiplayerENet.new()
	network.create_server(4242, 2)
	get_tree().set_network_peer(network)
	var _connect1 = get_tree().multiplayer.connect("network_peer_connected", self, "_peer_connected")
	var _connect2 = get_tree().multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	var _connect3 = get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")
	print("Hosting!")
	connected_type = "Server"
	
func start_client(ip):
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, 4242)
	get_tree().set_network_peer(network)
	var _connect1 = get_tree().multiplayer.connect("network_peer_connected", self, "_peer_connected")
	var _connect2 = get_tree().multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	var _connect3 = get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")
	print("Searching...")
	connected_type = "Client"
	
func _peer_connected(id):
	PlayerSettings.number_of_players = 2
	PlayerSettings.other_player_id = id
	if connected_type == "Server":
		PlayerSettings.my_player_index = 0
		print("Player connected! ID: " + str(id))
		var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["load level", CurrentLevelData.level_data.get_encoded_level_data(), PlayerSettings.player1_character, PlayerSettings.player2_character]).to_ascii())
		var _reload = get_tree().reload_current_scene()
	else:
		PlayerSettings.my_player_index = 1

func _peer_disconnected(id):
	print("Player disconnected. ID: " + str(id))
	connected_type = "None"
	PlayerSettings.other_player_id = -1
	PlayerSettings.my_player_index = 0

func _packet_recieved(_id, packet_ascii):
	var packet = JSON.parse(packet_ascii.get_string_from_ascii()).result
	if packet[0] == "load level":
		PlayerSettings.player1_character = packet[2]
		PlayerSettings.player2_character = packet[3]
		var level_data = LevelData.new()
		level_data.load_in(packet[1])
		CurrentLevelData.level_data = level_data
		
		yield(get_tree().create_timer(0.1), "timeout")
		var _reload = get_tree().reload_current_scene()
		var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["level loaded"]).to_ascii())
		get_tree().paused = false
	elif packet[0] == "level loaded":
		get_tree().paused = false
	elif packet[0] == "reload":
		get_tree().get_current_scene().get_node(get_tree().get_current_scene().character).kill("reload")
	elif packet[0] == "disconnect":
		disconnect_from_peers()	
		
func disconnect_from_peers():
	if get_tree().multiplayer.network_peer != null:
		var _send_bytes = get_tree().multiplayer.send_bytes(JSON.print(["disconnect"]).to_ascii())
		get_tree().multiplayer.set_network_peer(null)
	connected_type = "None"
	PlayerSettings.other_player_id = -1
	PlayerSettings.my_player_index = 0
