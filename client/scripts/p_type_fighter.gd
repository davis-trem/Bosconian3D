extends CharacterBody3D

const Util = preload('res://scripts/util.gd')


var speed = 8
var radius = 5
var randnum = randf()
var pos = Vector3.ZERO
var flip = false
var time := 0.0

func _ready():
	velocity = Vector3(0, 0, -1 * speed)
	pos = global_position


func _physics_process(delta):
	var closest_player = Util.get_closest_node(
		self,
		get_tree().get_nodes_in_group('player')
	)
	var player_pos = Util.get_closest_position(self, closest_player)
	
	if global_position.distance_to(player_pos) <= radius:
		look_at(player_pos)
		var direction = global_position.direction_to(
			_get_circle_position(player_pos)
		).normalized()
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		move_and_collide(velocity * delta)
		time = 0.2
		pos = global_position
	else:
		if time == 1:
			time = 0.0
			pos = global_position
			flip = not flip
		
		var p := _quadratic_bezier(
			pos,
			Vector3(player_pos.x, 0, pos.z) if flip else Vector3(player_pos.z, 0, pos.x),
			player_pos,
			time
		)
		if global_position.distance_to(p) < 0.1:
			time += 0.2
			
		look_at(player_pos)
		var direction = global_position.direction_to(p).normalized()
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		move_and_collide(velocity * delta)


func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var p00 := Vector2(p0.x, p0.z)
	var p11 := Vector2(p1.x, p1.z)
	var p22 := Vector2(p2.x, p2.z)
	
	var q0 := p00.lerp(p11, t)
	var q1 := p11.lerp(p22, t)
	var r := q0.lerp(q1, t)
	return Vector3(r.x, 0, r.y)


func _get_circle_position(target: Vector3) -> Vector3:
	var circle_center = target
	var angle = randnum * PI * 2
	
	return Vector3(
		circle_center.x + cos(angle) * 0.5,
		0,
		circle_center.z + sin(angle) * 0.5
	)
