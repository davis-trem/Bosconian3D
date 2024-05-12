extends Node

const astroid_scene = preload('res://scenes/astroid.tscn')
const cosmo_mine_scene = preload('res://scenes/cosmo_mine.tscn')
const enemy_base_scene = preload('res://scenes/enemy_base.tscn')
const i_type_fighter_scene = preload('res://scenes/i_type_fighter.tscn')
const p_type_fighter_scene = preload('res://scenes/p_type_fighter.tscn')
const player_scene = preload('res://scenes/player.tscn')
const spy_ship_scene = preload('res://scenes/spy_ship.tscn')
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
var weighted_enemy_types
var total_enemy_type_weight = 0.0
var spawn_enemies = false


func new_game():
	curr_round = 1
	game_play_screen.round_label.text = 'Round {0}'.format([curr_round])
	
	hi_score = 20000
	game_play_screen.hi_score_label.text = '{0}'.format([hi_score])
	
	score = 0
	game_play_screen.score_label.text = '{0}'.format([score])
	
	condition = ''
	lives = 3
	
	weighted_enemy_types = [
		{'name': 'i_type_fighter', 'type': i_type_fighter_scene, 'weight': 1.0},
		{'name': 'p_type_fighter', 'type': p_type_fighter_scene, 'weight': 1.0},
		{'name': 'spy_ship', 'type': spy_ship_scene, 'weight': 0.1},
#		{'name': 'formation', 'type': 'formation', 'weight': 0.25},
	]
	
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
	
	_init_enemy_type_probabilities()
	spawn_enemies = true
	_spawn_enemy_after_wait_time()
	
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
		player.camera_toggle.connect(game_play_screen.battle_field.on_player_camera_toggle)


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
		_handle_game_over()
	else:
		game_play_screen.respawn_container.show()
		game_play_screen.respawn_label.show()


func _handle_game_over():
	spawn_enemies = false
	print('game over')


func respawn_player():
	_add_player(local_player_multiplayer_unique_id)
	game_play_screen.respawn_container.hide()
	game_play_screen.respawn_label.hide()


func enemy_base_died(enemy_base, is_last_base = false):
	game_play_screen.mini_map.remove_base(enemy_base)
	if is_last_base:
		curr_round += 1
		spawn_enemies = false
		_start_round()


func _init_enemy_type_probabilities():
	# Update spawn probabilities for current level
	for weighted_enemy in weighted_enemy_types:
		if weighted_enemy['name'] == 'spy_ship':
			weighted_enemy['weight'] = clamp(curr_round * 0.1, 0.1, 0.7)
		if weighted_enemy['name'] == 'formation':
			weighted_enemy['weight'] = clamp(curr_round * 0.25, 0.25, 1)
	
	total_enemy_type_weight = 0.0
	for weighted_enemy in weighted_enemy_types:
		total_enemy_type_weight += weighted_enemy['weight']
		weighted_enemy['acumulated_weight'] = total_enemy_type_weight


func _get_random_enemy_type():
	var roll := randf_range(0.0, total_enemy_type_weight)
	for weighted_enemy in weighted_enemy_types:
		if weighted_enemy['acumulated_weight'] > roll:
			return weighted_enemy['type']

	# if sumn goes wrong return this basic ass enemy
	return i_type_fighter_scene


func _spawn_enemy_after_wait_time():
	if not spawn_enemies:
		return
	
	var wait_time = randi_range(8, 15)
	await get_tree().create_timer(float(wait_time)).timeout
	
	for i in range(4):
		var random_enemy_scene = _get_random_enemy_type()
		if random_enemy_scene is String and random_enemy_scene == 'formation':
			pass
		else:
			var enemy: CharacterBody3D = random_enemy_scene.instantiate()
			game_play_screen.battle_field.add_child(enemy)
			enemy.global_position = Util.SPAWN_POINTS[randi() % Util.SPAWN_POINTS.size()]
	
	_spawn_enemy_after_wait_time()
