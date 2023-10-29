extends StaticBody3D


signal has_died

func die():
	has_died.emit()
