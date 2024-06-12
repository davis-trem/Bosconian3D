extends Node

var multiplayer_peer := ENetMultiplayerPeer.new()
const port := 1909
const max_players := 100
var rooms = {} # RoomType { players: { [peer_id: int]: { instance_id: int, display_name: string } } }
const characters = 'abcdefghijklmnopqrstuvwxyz1234567890'


func _ready() -> void:
	_start_server()


func _start_server():
	multiplayer_peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = multiplayer_peer
	print('Server running...')
	
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)


@rpc('any_peer')
func create_room(display_name: String):
	print('creating room')
	var peer_id := multiplayer.get_remote_sender_id()
	var room_id := _generate_id()
	
	rooms[room_id] = {
		'players': {
			peer_id: {'display_name': display_name}
		}
	}
	
	room_successfully_joined.rpc_id(peer_id, room_id, display_name, rooms[room_id]['players'])


@rpc('any_peer')
func join_room(display_name: String, room_id: String):
	print('joining room')
	var peer_id := multiplayer.get_remote_sender_id()
	if room_id in rooms:
		if rooms[room_id]['players'].keys().size() == 4:
			unable_to_join_room.rpc_id(peer_id, room_id, 'Room {0} is full'.format([room_id]))
		elif peer_id in rooms[room_id]['players']:
			unable_to_join_room.rpc_id(
				peer_id,
				room_id,
				'User is already in room {0}'.format([room_id])
			)
		else:
			rooms[room_id]['players'][peer_id] = {'display_name': display_name}
			room_successfully_joined.rpc_id(
				peer_id,
				room_id,
				display_name,
				rooms[room_id]['players']
			)
			# Send to rest of the room
			for player_peer_id in rooms[room_id]['players'].keys():
				if player_peer_id != peer_id:
					room_successfully_joined.rpc_id(
						peer_id,
						room_id,
						display_name,
						rooms[room_id]['players']
					)
	else:
		unable_to_join_room.rpc_id(peer_id, room_id, 'room {0} does not exist'.format([room_id]))


func _on_peer_connected(peer_id: int):
	print('peer {0} connected'.format([peer_id]))


func _on_peer_disconnected(peer_id: int):
	print('peer {0} disconnected'.format([peer_id]))
	for room_id in rooms:
		if peer_id in rooms[room_id]['players']:
			rooms[room_id]['players'].erase(peer_id)
			return


func _generate_id() -> String:
	var id := ''
	var n_char := len(characters)
	for i in range(6):
		id += characters[randi()% n_char]
	return id if not id in rooms else _generate_id()

######### Client methods #########
@rpc('authority')
func room_successfully_joined(_room_id: String, _display_name: String, _players: Dictionary):
	pass


@rpc('authority')
func unable_to_join_room(_room_id: String, _error_msgn: String):
	pass
