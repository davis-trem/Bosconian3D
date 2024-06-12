extends Node

var multiplayer_peer := ENetMultiplayerPeer.new()
const host := '127.0.0.1'
const port := 1909
var game_room_id := ''
var game_players = {} # { [peer_id: int]: { instance_id: int, display_name: string } }

signal join_room_attempted(success: bool, error_msg: String)


func connect_to_server() -> void:
	print('connecting to server')
	multiplayer_peer.create_client(host, port)
	multiplayer.multiplayer_peer = multiplayer_peer


func disconnect_from_server() -> void:
	print('disconnecting from server')
	multiplayer_peer.disconnect_peer(1)
	multiplayer_peer.close()
	multiplayer.multiplayer_peer = null


func request_create_room(display_name: String):
	print('sent create room')
	create_room.rpc_id(1, display_name)


func request_join_room(display_name: String, room_id: String):
	join_room.rpc_id(1, display_name, room_id)


@rpc('authority')
func room_successfully_joined(room_id: String, display_name: String, players: Dictionary):
	prints('room joined', room_id, display_name)
	game_room_id = room_id
	game_players = players
	join_room_attempted.emit(true, '')


@rpc('authority')
func unable_to_join_room(room_id: String, error_msg: String):
	prints('room not joined', room_id, error_msg)
	join_room_attempted.emit(false, error_msg)


######### Server methods #########
@rpc('any_peer')
func create_room(_display_name: String):
	pass


@rpc('any_peer')
func join_room(_display_name: String, _room_id: String):
	pass
