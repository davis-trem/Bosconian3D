extends CharacterBody3D

const bullet_scene = preload('res://scenes/bullet.tscn')
const Util = preload('res://scripts/util.gd')


@onready var _collision_shape = $CollisionShape3D
@onready var _top_down_camera = $TopDownCamera3D
@onready var _cockpit_camera = $CockpitCamera3D
@onready var _front_projectile = $CollisionShape3D/FrontProjectile
@onready var _back_projectile = $CollisionShape3D/BackProjectile

signal has_died(position: Vector3)
signal camera_toggle(is_top_down: bool)

var speed = 9
var move_direction = Vector3(0, 0, -1)


func _ready():
	velocity = Vector3(0, 0, move_direction.z * speed)


func _input(event):
	if event.is_action_pressed('toggle_camera'):
		if _cockpit_camera.current:
			_collision_shape.rotation.y = rotation.y
			rotation.y = 0
			_top_down_camera.current = true
			camera_toggle.emit(true)
		elif _top_down_camera.current:
			rotation.y = _collision_shape.rotation.y
			_collision_shape.rotation.y = 0
			_cockpit_camera.current = true
			camera_toggle.emit(false)
	
	if event.is_action_pressed('ui_accept'):
		var front_bullet = bullet_scene.instantiate()
		front_bullet.fired_by_player = true
		front_bullet.global_transform = _front_projectile.global_transform
		var back_bullet = bullet_scene.instantiate()
		back_bullet.fired_by_player = true
		back_bullet.global_transform = _back_projectile.global_transform
		get_tree().current_scene.add_child(front_bullet)
		get_tree().current_scene.add_child(back_bullet)
		


func _physics_process(delta):
	if _cockpit_camera.current:
		handle_cockpit_movement()
	elif _top_down_camera.current:
		handle_top_down_movement()
	
	var collision := move_and_collide(velocity * delta)
	if collision:
		die()


func handle_top_down_movement():
	move_direction.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	move_direction.z = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	
	move_direction = move_direction.normalized()
	if move_direction != Vector3.ZERO:
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.z * speed
	
	var look_direction = Vector2(-velocity.z, -velocity.x)
	if _collision_shape.rotation.y != look_direction.angle():
		_collision_shape.rotation = _collision_shape.rotation.move_toward(
			Vector3(0, look_direction.angle(), 0),
			0.5
		)


func handle_cockpit_movement():
	var y_rotation = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if y_rotation != 0:
		rotation.y -= y_rotation * 0.05
		rotation.z = Vector3(0, 0, rotation.z).move_toward(Vector3(0, 0, -y_rotation * 0.2), 0.02).z

		var direction = Vector2(-cos(rotation.y), -sin(rotation.y)).normalized()
		velocity.x = direction.y * speed
		velocity.z = direction.x * speed
	else:
		rotation.z = Vector3(0, 0, rotation.z).move_toward(Vector3(0, 0, 0), 0.02).z


func die():
	has_died.emit(global_position)
	Util.explode(self)
	queue_free()
