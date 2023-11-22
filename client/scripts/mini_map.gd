extends Control

const Util = preload('res://scripts/util.gd')

var players_color_rect = {}
var bases_color_rect = {}


func _physics_process(delta):
	for player in players_color_rect.keys():
		if player != null:
			players_color_rect[player].position = _calculate_position(player.global_position)
		else:
			_remove_player(player)


func draw_player(player):
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(5, 5)
	color_rect.position = _calculate_position(player.global_position)
	players_color_rect[player] = color_rect
	add_child(color_rect)


func draw_base(enemy_base):
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(10, 10)
	color_rect.position = _calculate_position(enemy_base.global_position)
	color_rect.color = Color.DARK_GREEN
	bases_color_rect[enemy_base] = color_rect
	add_child(color_rect)


func _remove_player(player):
	var color_rect = players_color_rect.get(player)
	if (color_rect != null):
		color_rect.queue_free()
		players_color_rect.erase(player)


func remove_base(enemy_base):
	var color_rect = bases_color_rect.get(enemy_base)
	if (color_rect != null):
		color_rect.queue_free()
		bases_color_rect.erase(enemy_base)


func clear_map():
	for player in players_color_rect.keys():
		_remove_player(player)
	
	for base in bases_color_rect.keys():
		remove_base(base) 


func _calculate_position(pos: Vector3) -> Vector2:
	return Vector2(
		(pos.x + Util.FIELD_WIDTH) / (Util.FIELD_WIDTH * 2) * size.x,
		(pos.z + Util.FIELD_HEIGHT) / (Util.FIELD_HEIGHT * 2) * size.y
	)
