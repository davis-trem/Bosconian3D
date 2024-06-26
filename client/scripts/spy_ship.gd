extends "res://scripts/base_fighter.gd"

@onready var retreat_timer = $RetreatTimer


enum {
	PURSUE,
	RETREAT,
}

var state := PURSUE
var should_red_alert := false


func _physics_process(delta):
	if state == RETREAT:
		rotation.y = rotation.y + PI
		var closest_player = Util.get_closest_node(
			self,
			get_tree().get_nodes_in_group('player')
		)
		if closest_player == null:
			return
		var player_pos = Util.get_closest_position(self, closest_player)
		
		look_at(player_pos)
		if state == RETREAT:
			rotation.y = rotation.y + PI
	
		var direction = Vector2(-cos(rotation.y), -sin(rotation.y)).normalized()
		velocity.x = direction.y * speed
		velocity.z = direction.x * speed
		var collision = move_and_collide(velocity * delta)
		_handle_collision(collision)
	else:
		super(delta)


func _on_detection_area_body_entered(body: Node3D):
	if not body.is_in_group('player'):
		return
	
	match state:
		PURSUE:
			state = RETREAT
			speed = 8
			retreat_timer.start()
		RETREAT:
			retreat_timer.start()


func _on_retreat_timer_timeout():
	if should_red_alert:
		queue_free()
	else:
		state = PURSUE
		speed = 7
		should_red_alert = true
