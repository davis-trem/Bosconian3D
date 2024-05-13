extends CharacterBody3D

const Util = preload('res://scripts/util.gd')

var points = 50
var speed = 4


func _ready():
	velocity = Vector3(0, 0, -1 * speed)


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
