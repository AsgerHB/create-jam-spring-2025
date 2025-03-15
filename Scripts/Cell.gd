extends Node2D
class_name Cell

const CELL_SIZE: int = 32

enum Type {
	Standard
}

@export var type: Type = Type.Standard;

# NOTE: Local coord if in falling tetriminos
var grid_pos: Vector2i

func _draw() -> void:
	const rec = Rect2(-CELL_SIZE / 2, -CELL_SIZE / 2, CELL_SIZE, CELL_SIZE)
	# TODO: Use sprites
	if type == Type.Standard:
		draw_rect(rec, Color.RED)
	else:
		draw_rect(rec, Color.MAGENTA)
