extends Node

const player_scene = preload('res://scenes/player.tscn')

var game_play_screen: Control
var curr_round = 1
var score = 0
var hi_score = 20000
var points_until_new_life = 0
var condition = ''
var lives = 3
var players = {}
var local_player_multiplayer_unique_id


func new_game():
	curr_round = 1
	game_play_screen.round_label.text = 'Round {0}'.format([curr_round])
	
	hi_score = 20000
	game_play_screen.hi_score_label.text = '{0}'.format([hi_score])
	
	score = 0
	game_play_screen.score_label.text = '{0}'.format([score])
	
	condition = ''
	lives = 3
	
	_draw_lives()
	
	players = {}
	var multiplayer_unique_id = multiplayer.get_unique_id()
	_add_player(multiplayer_unique_id)


func _add_player(peer_id):
	set_multiplayer_authority(peer_id)
	
	var player = player_scene.instantiate()
	player.id = peer_id
	players[peer_id] = player
	game_play_screen.battle_field.add_child(player)
	game_play_screen.mini_map.draw_player(player)
	
	if peer_id == multiplayer.get_unique_id():
		local_player_multiplayer_unique_id = peer_id
		player.has_died.connect(game_play_screen.battle_field.on_player_has_died)


func _draw_lives():
	for index in game_play_screen.lives_container.get_child_count():
		game_play_screen.lives_container.get_child(index).visible = index < lives


func increase_score(points):
	score += points
	game_play_screen.score_label.text = '{0}'.format([score])
	
	if score > hi_score:
		hi_score = score
		game_play_screen.hi_score_label.text = '{0}'.format([hi_score])
	
	points_until_new_life += points
	if points_until_new_life >= 20000:
		points_until_new_life = 0
		if lives < 4:
			lives += 1
			_draw_lives()


func player_died(peer_id):
	lives -= 1
	_draw_lives()
	
	if lives == 0:
		print('game over')
	else:
		await get_tree().create_timer(2.0).timeout
		_add_player(peer_id)


func enemy_base_died():
	if game_play_screen.get_tree().get_nodes_in_group('enemy_base').size() == 0:
		curr_round += 1
