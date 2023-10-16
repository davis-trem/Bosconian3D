extends CharacterBody3D

const Util = preload('res://scripts/util.gd')


var speed = 4
var radius = 3
var randnum = randf()

func _ready():
	velocity = Vector3(0, 0, -1 * speed)


func _physics_process(delta):
	var closest_player = Util.get_closest_node(
		self,
		get_tree().get_nodes_in_group('player')
	)
	
	var new_position = Util.get_closest_position(self, closest_player)
	if global_position.distance_to(new_position) > radius:
		new_position = _get_circle_position(new_position)

	var direction = global_position.direction_to(new_position).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	move_and_collide(velocity * delta)

	look_at(new_position)


func _get_circle_position(target: Vector3) -> Vector3:
	var circle_center = target
	var angle = randnum * PI * 2
	
	return Vector3(
		circle_center.x + cos(angle) * radius,
		0,
		circle_center.z + sin(angle) * radius
	)
