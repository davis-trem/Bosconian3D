extends Node3D

const Util = preload('res://scripts/util.gd')


@onready var border_area = $BorderArea
@onready var border_area_shape = $BorderArea/CollisionShape3D
@onready var spectador_camera = $SpectadorCamera
@onready var top_down_sky_box = $TopDownSkyBox

var mirrored_items = {}


func _ready() -> void:
	top_down_sky_box.play('default')
	# Fix for area detection bug https://github.com/godotengine/godot/issues/74300#issuecomment-1519064875
	# Considering "area" an Area3D, and layer 32 an unused layer
	border_area.set_collision_layer_value(32, not border_area.get_collision_layer_value(32))


func _physics_process(delta: float) -> void:
	for key in mirrored_items.keys():
		if key == null:
			mirrored_items[key].queue_free()
			mirrored_items.erase(key)
		else:
			mirrored_items[key].global_position = Util.get_mirror_border_position(key)


func _on_border_area_body_exited(body: Node3D):
	if Util.FIELD_WIDTH <= abs(body.global_position.x):
		body.global_position.x = -body.global_position.x
	if Util.FIELD_HEIGHT <= abs(body.global_position.z):
		body.global_position.z = -body.global_position.z


func _on_border_area_area_exited(area):
	if Util.FIELD_WIDTH <= abs(area.global_position.x):
		area.global_position.x = -area.global_position.x
	if Util.FIELD_HEIGHT <= abs(area.global_position.z):
		area.global_position.z = -area.global_position.z


func on_player_has_died(position):
	spectador_camera.global_position = position
	spectador_camera.current = true


func on_player_camera_toggle(is_top_down):
	if is_top_down:
		top_down_sky_box.show()
	else:
		top_down_sky_box.hide()


func empty_field():
	for enemy in get_tree().get_nodes_in_group('enemy'):
		enemy.queue_free()
	
	for obstacle in get_tree().get_nodes_in_group('obstacle'):
		obstacle.queue_free()


func _on_mirror_area_body_exited(body: Node3D) -> void:
	if body.is_in_group('player'):
		return
	mirrored_items[body] = body.duplicate()
	add_child(mirrored_items[body])


func _on_mirror_area_body_entered(body: Node3D) -> void:
	if mirrored_items.has(body):
		mirrored_items[body].queue_free()
		mirrored_items.erase(body)


func _on_mirror_area_area_exited(area: Area3D) -> void:
	mirrored_items[area] = area.duplicate()
	add_child(mirrored_items[area])


func _on_mirror_area_area_entered(area: Area3D) -> void:
	if mirrored_items.has(area):
		mirrored_items[area].queue_free()
		mirrored_items.erase(area)
