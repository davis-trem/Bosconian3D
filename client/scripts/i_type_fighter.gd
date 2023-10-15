extends CharacterBody3D

const Util = preload('res://scripts/util.gd')


var speed = 4


func _ready():
	velocity = Vector3(0, 0, -1 * speed)


func _physics_process(delta):
	var closest_player = Util.get_closest_node(
		self,
		get_tree().get_nodes_in_group('player')
	)
	
	look_at(Util.get_closest_position(self, closest_player))
	
	var direction = Vector2(-cos(rotation.y), -sin(rotation.y)).normalized()
	velocity.x = direction.y * speed
	velocity.z = direction.x * speed
	
	move_and_collide(velocity * delta)
