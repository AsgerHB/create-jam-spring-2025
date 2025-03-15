extends Node2D
class_name Cell

const CELL_SIZE: int = 32

enum Type {
	Standard,
	Sand,
}
# Map that assigns a complexity score to each cell type
const cell_complexity_score = {
	Type.Standard: 1,
	Type.Sand: 2,
}

# All the different states that a sprite can be in
enum State {
	CellTopLeft,
	CellTop,
	CellTopRight,
	CellRight,
	CellMiddle,
	CellLeft,
	CellBottomRight,
	CellBottom,
	CellBottomLeft,
	EndLeft,
	EndTop,
	EndRight,
	EndBottom,
	TTop,
	TLeft,
	TRight,
	TBottom,
	Horizontal,
	Vertical,
	Single,
	CornerTopRight,
	CornerTopLeft,
	CornerButtomRight,
	CornerButtomLeft
}
# A mapping of a sprite's state and where it maps to in the sprite sheet
const SpriteCoords: Dictionary[State, Vector2i] = {
	State.CellTopLeft: Vector2i(0,0),
	State.CellTop: Vector2i(8,0),
	State.CellTopRight: Vector2i(16,0),
	State.EndLeft: Vector2i(24,0),
	State.EndBottom: Vector2i(32,0),
	State.TRight: Vector2i(40,0),
	State.CellLeft: Vector2i(0,8),
	State.CellMiddle: Vector2i(8,8),
	State.CellRight: Vector2i(16,8),
	State.EndTop: Vector2i(24,8),
	State.EndRight: Vector2i(32,8),
	State.TTop: Vector2i(40,8),
	State.CellBottomLeft: Vector2i(0,16),
	State.CellBottom: Vector2i(8,16),
	State.CellBottomRight: Vector2i(16,16),
	State.CornerTopLeft: Vector2i(24,16),
	State.CornerTopRight: Vector2i(32,16),
	State.TLeft: Vector2i(40,16),
	State.Horizontal: Vector2i(0,24),
	State.Vertical: Vector2i(8,24),
	State.Single: Vector2i(16,24),
	State.CornerButtomLeft: Vector2i(24,24),
	State.CornerButtomRight: Vector2i(32,24),
	State.TBottom: Vector2i(40,24),
}

@export var type: Type = Type.Standard;
@export var sprite_state: State = State.CellMiddle
@export var sprite_sheet: Texture2D:
	set(value):
		sprite_sheet = value
		queue_redraw()


# NOTE: Local coord if in falling tetriminos
var grid_pos: Vector2i

func _draw() -> void:
	const rec = Rect2(-CELL_SIZE / 2, -CELL_SIZE / 2, CELL_SIZE, CELL_SIZE)
	var sprite_coords = SpriteCoords[sprite_state]
	draw_texture_rect_region(sprite_sheet,rec, Rect2(sprite_coords.x, sprite_coords.y, 8,8))
	# TODO: Use, 
	#if type == Type.Standard:
	#	draw_rect(rec, Color.RED)
	#else:
	#	draw_rect(rec, Color.MAGENTA)


func on_destroy(game: TetrisGame) -> bool:
	# Returns true if the cell can be destroyed
	# TODO: Score points
	# TODO: Cool effects go here
	return true


func on_move(game: TetrisGame, to_x: int, to_y: int) -> bool:
	# Returns true if the cell can be moved
	# TODO: Cool effects go here
	return true

func on_tick(game: TetrisGame, tick: int):
	# Updates the game state for this tick
	match type:
		Type.Sand:
			if tick % 3 == 0:
				game.try_move_cell(grid_pos.x, grid_pos.y, grid_pos.x, grid_pos.y + 1)
