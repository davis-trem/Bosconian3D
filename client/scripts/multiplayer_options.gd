extends Control

@onready var display_name_line_edit: LineEdit = $MarginContainer/VBoxContainer/DisplayNameLineEdit
@onready var room_id_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/RoomIDLineEdit
@onready var error_label: Label = $MarginContainer/VBoxContainer/ErrorLabel
@onready var server_connection_label: Label = $MarginContainer/VBoxContainer/ServerConnectionLabel
@onready var create_room_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CreateRoomButton
@onready var join_room_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/JoinRoomButton


func _ready() -> void:
	Server.connect_to_server()
	Server.join_room_attempted.connect(_on_join_room_attempted)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _on_connected_to_server():
	create_room_button.disabled = false
	join_room_button.disabled = false
	server_connection_label.text = 'Connected to server'


func _on_connection_failed():
	server_connection_label.text = 'Failed to connected to server'


func _on_join_room_attempted(success: bool, error_msg: String):
	prints('_on_join_room_attempted', success, error_msg)
	if success:
		get_tree().change_scene_to_file('res://screens/room_lobby.tscn')
	else:
		error_label.text = error_msg


func _on_create_room_button_pressed() -> void:
	error_label.text = ''
	if display_name_line_edit.text == '':
		error_label.text = 'Display name input missing'
		return
	
	Server.request_create_room(display_name_line_edit.text)


func _on_join_room_button_pressed() -> void:
	error_label.text = ''
	if display_name_line_edit.text == '':
		error_label.text = 'Display name input missing'
		return
	
	if room_id_line_edit.text == '':
		error_label.text = 'Room ID input missing'
	
	Server.request_join_room(display_name_line_edit.text, room_id_line_edit.text)


func _on_back_button_pressed() -> void:
	error_label.text = ''
	Server.disconnect_from_server()
	get_tree().change_scene_to_file('res://screens/main_menu.tscn')
