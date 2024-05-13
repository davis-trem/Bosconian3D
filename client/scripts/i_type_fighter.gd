extends "res://scripts/base_fighter.gd"


func _ready():
	super()
	points = 50
	speed = 4


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
	_handle_collision(collision)
