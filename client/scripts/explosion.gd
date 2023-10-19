extends GPUParticles3D

var time := 0.0


func _process(delta):
	time += delta
	if time >= lifetime:
		queue_free()
