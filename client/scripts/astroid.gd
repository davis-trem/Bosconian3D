extends StaticBody3D

const Util = preload('res://scripts/util.gd')

var points = 10


func _ready():
	rotation.y = randf_range(0, PI)


func die():
	Util.explode(self)
	GameProgress.increase_score(points)
	queue_free()
