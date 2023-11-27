extends Node

const astroid_scene = preload('res://scenes/astroid.tscn')
const cosmo_mine_scene = preload('res://scenes/cosmo_mine.tscn')
const enemy_base_scene = preload('res://scenes/enemy_base.tscn')
const player_scene = preload('res://scenes/player.tscn')
const Util = preload('res://scripts/util.gd')

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
	_start_round()


func _start_round():
	game_play_screen.ready_label.text = 'READY ROUND {0}'.format([curr_round])
	game_play_screen.ready_container.show()
	
	for player_peer_id in players.keys():
		if players.get(player_peer_id):
			players[player_peer_id].queue_free()

	var multiplayer_unique_id = multiplayer.get_unique_id()
	_add_player(multiplayer_unique_id)
	
	_spawn_enemy_bases_and_obstacles()
	
	get_tree().paused = true
	await get_tree().create_timer(3.0).timeout
	get_tree().paused = false
	game_play_screen.ready_container.hide()


func _spawn_enemy_bases_and_obstacles():
	game_play_screen.battle_field.empty_field()
	var base_count = 8 if curr_round >= 3 else curr_round + 2
	var obstacles = []
	for i in base_count:
		var enemy_base = enemy_base_scene.instantiate()
		game_play_screen.battle_field.add_child(enemy_base)
		enemy_base.global_position = Util.generate_spawn_point(3.5, obstacles)
		game_play_screen.mini_map.draw_base(enemy_base)
		obstacles.append(enemy_base)
	
	var obstacle_spawn_radius = 1
	for i in 20:
		var astroid = astroid_scene.instantiate()
		game_play_screen.battle_field.add_child(astroid)
		astroid.global_position = Util.generate_spawn_point(3.5, obstacles)
		obstacles.append(astroid)

	for i in 10:
		var cosmo_mine = cosmo_mine_scene.instantiate()
		game_play_screen.battle_field.add_child(cosmo_mine)
		cosmo_mine.global_position = Util.generate_spawn_point(3.5, obstacles)
		obstacles.append(cosmo_mine)


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
		game_play_screen.respawn_container.show()
		game_play_screen.respawn_label.show()


func respawn_player():
	_add_player(local_player_multiplayer_unique_id)
	game_play_screen.respawn_container.hide()
	game_play_screen.respawn_label.hide()


func enemy_base_died(enemy_base, is_last_base = false):
	game_play_screen.mini_map.remove_base(enemy_base)
	if is_last_base:
		curr_round += 1
		_start_round()
