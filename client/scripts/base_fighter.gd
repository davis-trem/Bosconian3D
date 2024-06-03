extends CharacterBody3D

const Util = preload('res://scripts/util.gd')

@export var points = 50
@export var speed = 7
@export var mass = 60
@onready var ray_cast_3d_up: RayCast3D = $RayCast3DUp
@onready var ray_cast_3d_up_right: RayCast3D = $RayCast3DUpRight
@onready var ray_cast_3d_right: RayCast3D = $RayCast3DRight
@onready var ray_cast_3d_down_right: RayCast3D = $RayCast3DDownRight
@onready var ray_cast_3d_down: RayCast3D = $RayCast3DDown
@onready var ray_cast_3d_down_left: RayCast3D = $RayCast3DDownLeft
@onready var ray_cast_3d_left: RayCast3D = $RayCast3DLeft
@onready var ray_cast_3d_up_left: RayCast3D = $RayCast3DUpLeft
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var vector_directions = [
	Vector3(0, 0, -1),
	Vector3(1, 0, -1),
	Vector3(1, 0, 0),
	Vector3(1, 0, 1),
	Vector3(0, 0, 1),
	Vector3(-1, 0, 1),
	Vector3(-1, 0, 0),
	Vector3(-1, 0, -1),
]

func _ready():
	velocity = Vector3(0, 0, -1 * speed)


func _physics_process(delta: float) -> void:
	var closest_player = Util.get_closest_node(
		self,
		get_tree().get_nodes_in_group('player')
	)
	if closest_player == null:
		return
	var player_pos = Util.get_closest_position(self, closest_player)
	
	var direction_to_player := global_position.direction_to(player_pos)
	
	var interest_vector_array = _calculate_interest_vector_array(direction_to_player)
	var danger_array = _calculate_danger_array()
	
	var greatest_context_value
	var greatest_context_value_index
	for index in range(len(interest_vector_array)):
		var context_value = interest_vector_array[index] - danger_array[index]
		if greatest_context_value == null or context_value > greatest_context_value:
			greatest_context_value = context_value
			greatest_context_value_index = index
	
	if greatest_context_value_index != null:
		var best_direction: Vector3 = vector_directions[greatest_context_value_index]
		if direction_to_player.dot(best_direction) > 0.9:
			best_direction = direction_to_player
		
		var desired_velocity = best_direction * speed
		var steering = (desired_velocity - velocity) / mass
		
		rotation = Vector3(0, Vector2(-velocity.z, -velocity.x).angle(), 0)
		velocity += steering
		var collision = move_and_collide(velocity * delta)
		_handle_collision(collision)


func _calculate_interest_vector_array(direction_to_player: Vector3) -> Array:
	return vector_directions.map(func (vec: Vector3): return direction_to_player.dot(vec))


func _calculate_danger_array() -> Array:
	var ray_casts: Array[RayCast3D] = [
		ray_cast_3d_up,
		ray_cast_3d_up_right,
		ray_cast_3d_right,
		ray_cast_3d_down_right,
		ray_cast_3d_down,
		ray_cast_3d_down_left,
		ray_cast_3d_left,
		ray_cast_3d_up_left,
	]
	var danger_array = [0, 0, 0, 0, 0, 0, 0, 0]
	for index in range(len(ray_casts)):
		var collider = ray_casts[index].get_collider()
		if collider != null and  collider.is_in_group('enemy'):
			danger_array[index] = 5
			var prevIndex = wrapi(index - 1, 0, len(danger_array))
			var nextIndex = wrapi(index - 1, 0, len(danger_array))
			if danger_array[prevIndex] == 0:
				danger_array[prevIndex] = 2
			if danger_array[nextIndex] == 0:
				danger_array[nextIndex] = 2
	
	return danger_array


func _handle_collision(collision: KinematicCollision3D) -> void:
	if collision:
		var collider = collision.get_collider()
		if collider.has_method('die') and not collider is CharacterBody3D:
			collider.die()
		die()


func die():
	Util.explode(self)
	GameProgress.increase_score(points)
	queue_free()
