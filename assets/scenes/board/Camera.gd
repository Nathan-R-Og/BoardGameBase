extends Camera2D

@export var following = true

func _process(delta):
	if following: position = $"../Players".get_child(get_parent().currentP).position
	align()
