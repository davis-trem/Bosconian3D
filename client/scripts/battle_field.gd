extends Node3D

const Util = preload('res://scripts/util.gd')


@onready var border_area = $BorderArea
@onready var border_area_shape = $BorderArea/CollisionShape3D
@onready var spectador_camera = $SpectadorCamera
@onready var top_down_sky_box = $TopDownSkyBox
@onready var top_down_mirrors = $TopDownMirrors


func _physics_process(delta):
	top_down_sky_box.play('default')
	# Fix for area detection bug https://github.com/godotengine/godot/issues/74300#issuecomment-1519064875
	# Considering "area" an Area3D, and layer 32 an unused layer
	border_area.set_collision_layer_value(32, not border_area.get_collision_layer_value(32))


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


func _on_player_camera_toggle(is_top_down):
	if is_top_down:
		top_down_mirrors.show()
		top_down_sky_box.show()
	else:
		top_down_mirrors.hide()
		top_down_sky_box.hide()


func empty_field():
	for enemy in get_tree().get_nodes_in_group('enemy'):
		enemy.queue_free()
	
	for obstacle in get_tree().get_nodes_in_group('obstacle'):
		obstacle.queue_free()
