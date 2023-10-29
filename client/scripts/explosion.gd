extends GPUParticles3D

signal explosion_finished
var time := 0.0


func _process(delta):
	time += delta
	if time >= lifetime:
		explosion_finished.emit()
		queue_free()
