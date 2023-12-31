extends Node

const explosion_scene = preload('res://scenes/explosion.tscn')

const FIELD_HEIGHT = 56
const FIELD_WIDTH = 32

const SPAWN_POINTS = [
	Vector3(0, 0, FIELD_HEIGHT + 5),
	Vector3(0, 0, -FIELD_HEIGHT - 5),
	Vector3(FIELD_WIDTH + 5, 0, 0),
	Vector3(-FIELD_WIDTH - 5, 0, 0),
]

static func get_mirror_border_position(node: Node3D) -> Vector3:
	var margin = 16
	
	var position = node.global_position
	var mirrored_position = position
	
	if FIELD_WIDTH - abs(position.x) <= margin:
		mirrored_position.x = ((FIELD_WIDTH - abs(position.x) + FIELD_WIDTH) * (-1 if position.x > 0 else 1))
	if FIELD_HEIGHT - abs(position.z) <= margin:
		mirrored_position.z = ((FIELD_HEIGHT - abs(position.z) + FIELD_HEIGHT) * (-1 if position.z > 0 else 1))
		
	return mirrored_position


static func get_closest_position(node: Node3D, target: Node3D) -> Vector3:
	var direct_dist = node.global_position.distance_to(target.global_position)
	var mirrored_postition = get_mirror_border_position(target)
	var mirrored_dist = node.global_position.distance_to(mirrored_postition)
	return target.global_position if direct_dist < mirrored_dist else mirrored_postition


static func get_closest_node(node: Node3D, targets: Array[Node]):
	return targets.reduce(
		func (closest, p): 
			return (
				p if (
					closest == null or
					node.global_position.distance_to(get_closest_position(node, p)) < \
					node.global_position.distance_to(get_closest_position(node, closest))
				)
				else closest)
	)


static func explode(node: Node3D):
	var explosion := explosion_scene.instantiate()
	node.get_tree().current_scene.add_child(explosion)
	explosion.global_position = node.global_position
	explosion.emitting = true


static func generate_spawn_point(radius: float, avoidables: Array) -> Vector3:
	var x = randf_range(-FIELD_WIDTH + radius, FIELD_WIDTH - radius)
	var z = randf_range(-FIELD_WIDTH + radius, FIELD_WIDTH - radius)
	
	while (-radius < x and x < radius) or avoidables.any(func (node): (
		(node.global_position.x - radius < x and x < node.global_position.x + radius)
		and (node.global_position.z - radius < z and z < node.global_position.z + radius)
	)):
		x = randf_range(-FIELD_WIDTH + radius, FIELD_WIDTH - radius)
		z = randf_range(-FIELD_HEIGHT + radius, FIELD_HEIGHT - radius)
	
	return Vector3(x, 0, z)
