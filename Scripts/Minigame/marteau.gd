extends Area2D

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseMotion:
		global_position = event.position
