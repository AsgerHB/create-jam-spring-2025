extends Tetriminos
class_name TetriminosAnimated

var falling_speed = 1
var rotation_speed = 1
var y_max = 1080

func _process(delta: float) -> void:
	position.y = position.y + delta*falling_speed
	rotation = rotation + delta*rotation_speed
	if position.y > y_max:
		queue_free()
