extends Node2D
class_name Cell

const CELL_SIZE: int = 32

enum Type {
	Standard
}

# Map that assigns a complexity score to each cell type
const cell_complexity_score = {
	Type.Standard: 1
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


func on_destroy(game: TetrisGame) -> bool:
	# Returns true if the cell can be destroyed
	# TODO: Score points
	# TODO: Cool effects go here
	return true


func on_move(game: TetrisGame, to_x: int, to_y: int) -> bool:
	# Returns true if the cell can be moved
	# TODO: Cool effects go here
	return true
