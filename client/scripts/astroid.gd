extends StaticBody3D

const Util = preload('res://scripts/util.gd')


func _ready():
	rotation.y = randf_range(0, PI)


func die():
	Util.explode(self)
	queue_free()
