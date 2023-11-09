extends StaticBody3D

const explosion_scene = preload('res://scenes/explosion.tscn')
const Util = preload('res://scripts/util.gd')

@onready var explosion_impact = $ExplosionImpact
@onready var explosion_impact_collision_shape = $ExplosionImpact/CollisionShape3D
@onready var body = $Body

var points = 20
var explosion_should_damage = false


func _physics_process(delta):
	if explosion_should_damage and (explosion_impact_collision_shape.shape as SphereShape3D).radius < 2.5:
		(explosion_impact_collision_shape.shape as SphereShape3D).radius += 0.15


func die():
	body.hide()
	explosion_should_damage = true
	
	var explosion := explosion_scene.instantiate()
	explosion.explosion_finished.connect(_on_explosion_finished)
	explosion.scale = Vector3(2, 2, 2)
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true
	GameProgress.increase_score(points)


func _on_explosion_finished():
	queue_free()


func _on_explosion_impact_body_entered(body):
	if explosion_should_damage and body.has_method('die'):
		body.die()
