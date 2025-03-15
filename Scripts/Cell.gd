extends Node2D
class_name Cell

const CELL_SIZE: int = 32

enum Type {
	Standard,
	Compressed,
	Sand,
	Balloon,
	Gold,
	Bomb,
}
# Map that assigns a complexity score to each cell type
const cell_complexity_score = {
	Type.Standard: 1,
	Type.Sand: 2,
	Type.Compressed: 2,
	Type.Balloon: 2,
	Type.Gold: 2,
	Type.Bomb: 3,
}
# A mapping of a sprite's state and where it maps to in the sprite sheet
const SpriteCoords: Dictionary[Type, Vector2i] = {
	Type.Standard: Vector2i(0,0),
	Type.Sand: Vector2i(8,0),
	Type.Gold: Vector2i(0,8),
	Type.Bomb: Vector2i(8,8),
	Type.Compressed: Vector2i(0,16),
	Type.Balloon: Vector2i(8,16)
}

@export var type: Type = Type.Standard;
@export var sprite_sheet: Texture2D:
	set(value):
		sprite_sheet = value
		queue_redraw()
@export var explosion_particle: PackedScene

# NOTE: Local coord if in falling tetriminos
var grid_pos: Vector2i

func _draw() -> void:
	const rec = Rect2(-CELL_SIZE / 2, -CELL_SIZE / 2, CELL_SIZE, CELL_SIZE)
	var sprite_coords = SpriteCoords[type]
	draw_texture_rect_region(sprite_sheet, rec, Rect2(sprite_coords.x, sprite_coords.y, 8,8))

func destroy(game: TetrisGame):
	# Do effects
	match type:
		Type.Bomb:
			var particle_instance = explosion_particle.instantiate()
			get_parent().add_child(particle_instance)
			particle_instance.position = grid_pos * CELL_SIZE
			particle_instance.emitting = true
			game.remove_at(grid_pos.x, grid_pos.y)
			# Destroy all surrounding blocks
			for offset in [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)]:
				var res_grid_pos = grid_pos + offset
				var n = game.get_at(res_grid_pos.x, res_grid_pos.y)
				if n != null:
					n.destroy(game)
		_:
			game.remove_at(grid_pos.x, grid_pos.y)
	

	# Do scoring
	var score
	match type:
		Type.Gold:
			score = 20
		_:
			score = 5
	game.score_counter.apply_score(score, grid_pos * CELL_SIZE)

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
		Type.Balloon:
			if tick % 3 == 0:
				if grid_pos.y == 0:
					game.remove_at(grid_pos.x, grid_pos.y)
				else:
					game.try_move_cell(grid_pos.x, grid_pos.y, grid_pos.x, grid_pos.y - 1)
		Type.Gold:
			if tick % 12 == 0:
				game.score_counter.apply_score(1, position)
