extends Control

@onready var battle_field = $HBoxContainer/SubViewportContainer/SubViewport/BattleField
@onready var mini_map = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/MiniMap
@onready var hi_score_label = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HiScoreLabel
@onready var score_label = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/ScoreLabel
@onready var condition_label = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/ConditionLabel
@onready var lives_container = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/LivesContainer
@onready var round_label = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/RoundLabel
@onready var respawn_container = $HBoxContainer/SubViewportContainer/RespawnContainer
@onready var respawn_label = $HBoxContainer/SubViewportContainer/RespawnContainer/RespawnLabel
@onready var ready_container = $HBoxContainer/SubViewportContainer/ReadyContainer
@onready var ready_label = $HBoxContainer/SubViewportContainer/ReadyContainer/ReadyLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	GameProgress.game_play_screen = self
	GameProgress.new_game()


func _input(event):
	if event.is_action_pressed('ui_accept') and respawn_container.visible and respawn_label.visible:
		GameProgress.respawn_player()
		
