extends Area3D


@onready var shape = $CollisionShape3D

const KILL_TIME = 3
var kill_timer = 0
var speed = 30
var velocity = Vector3.ZERO
var fired_by_player = false


func _ready():
	if not fired_by_player:
		scale.x = 0.8
		speed = 20
	else:
		set_collision_mask_value(1, false)


func _physics_process(delta):
	var forward_direction = global_transform.basis.z.normalized() 
	global_translate(forward_direction * delta * speed)
	
	if not fired_by_player:
		shape.rotation.y += 0.3
	
	kill_timer += delta
	if kill_timer > KILL_TIME:
		queue_free()


func _on_body_entered(body: Node3D):
	if body.has_method('die'):
		body.die()
	queue_free()
