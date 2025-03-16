extends Node2D

var is_down: bool = false

func _ready() -> void:
	while true:
		if is_down:
			position.y -= 16
		else:
			position.y += 16
		is_down = !is_down
		await get_tree().create_timer(1.4166667).timeout
