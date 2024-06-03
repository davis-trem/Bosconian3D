extends Control

@onready var single_player_button: Button = $MarginContainer/VBoxContainer/VBoxContainer/SinglePlayerButton


func _ready() -> void:
	single_player_button.grab_focus()


func _on_single_player_button_pressed() -> void:
	get_tree().change_scene_to_file('res://screens/game_play_screen.tscn')


func _on_multi_player_button_pressed() -> void:
	get_tree().change_scene_to_file('res://screens/game_play_screen.tscn')


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
