extends Node3D


@onready var border_area = $BorderArea
@onready var border_area_shape = $BorderArea/CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready():
	print('working....')
	pass # Replace with function body.


func _physics_process(delta):
	# Fix for area detection bug https://github.com/godotengine/godot/issues/74300#issuecomment-1519064875
	# Considering "area" an Area3D, and layer 32 an unused layer
	border_area.set_collision_layer_value(32, not border_area.get_collision_layer_value(32))


func _on_border_area_body_exited(body: Node3D):
	var direction = body.velocity.normalized()
	if direction.x != 0:
		body.global_position.x = -body.global_position.x
	if direction.z != 0:
		body.global_position.z = -body.global_position.z
	pass # Replace with function body.
