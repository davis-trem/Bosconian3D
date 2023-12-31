extends CharacterBody3D

const Util = preload('res://scripts/util.gd')

var points = 50
var speed = 4


func _ready():
	velocity = Vector3(0, 0, -1 * speed)


func _physics_process(delta):
	var closest_player = Util.get_closest_node(
		self,
		get_tree().get_nodes_in_group('player')
	)
	if closest_player == null:
		return
	var player_pos = Util.get_closest_position(self, closest_player)
	
	look_at(player_pos)
	
	var direction = Vector2(-cos(rotation.y), -sin(rotation.y)).normalized()
	velocity.x = direction.y * speed
	velocity.z = direction.x * speed
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method('die') and not collider is CharacterBody3D:
			collider.die()
		die()


func die():
	Util.explode(self)
	GameProgress.increase_score(points)
	queue_free()
