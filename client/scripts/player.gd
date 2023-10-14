extends StaticBody3D


@onready var _collision_shape = $CollisionShape3D
@onready var _top_down_camera = $TopDownCamera3D
@onready var _cockpit_camera = $CockpitCamera3D

@export var speed = 9

var move_direction = Vector3(0, 0, -1)
var velocity = Vector3(0, 0, move_direction.z * speed)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed('toggle_camera'):
		if _cockpit_camera.current:
			_collision_shape.rotation.y = rotation.y
			rotation.y = 0
			_top_down_camera.current = true
		elif _top_down_camera.current:
			rotation.y = _collision_shape.rotation.y
			_collision_shape.rotation.y = 0
			_cockpit_camera.current = true


func _physics_process(delta):
	if _cockpit_camera.current:
		handle_cockpit_movement()
	elif _top_down_camera.current:
		handle_top_down_movement()
	
	move_and_collide(velocity * delta)


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

