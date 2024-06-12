extends Control

@onready var room_label: Label = $MarginContainer/VBoxContainer/RoomLabel
@onready var players_label: Label = $MarginContainer/VBoxContainer/PlayersLabel
@onready var players_v_box_container: VBoxContainer = $MarginContainer/VBoxContainer/PlayersVBoxContainer


func _ready() -> void:
	Server.join_room_attempted.connect(_draw_players_names)
	room_label.text = 'Room {0} Lobby'.format([Server.game_room_id])
	_draw_players_names()


func _draw_players_names() -> void:
	for node in players_v_box_container.get_children():
		players_v_box_container.remove_child(node)
		node.queue_free()
	
	for player in Server.game_players.values():
		var label := players_label.duplicate()
		label.text = player['display_name']
		players_v_box_container.add_child(label)
	


func _on_start_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_room_button_pressed() -> void:
	Server.disconnect_from_server()
	get_tree().change_scene_to_file('res://screens/multiplayer_options.tscn')
