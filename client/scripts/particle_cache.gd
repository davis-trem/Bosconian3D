extends Node

var explosion_scene = preload('res://scenes/explosion.tscn')


func _ready():
	var e: GPUParticles3D = explosion_scene.instantiate()
	e.emitting = true
	add_child(e)
