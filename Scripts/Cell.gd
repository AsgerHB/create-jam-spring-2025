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
	Concrete,
	ConcreteSemiBroken,
	Clock,
	Gift,
	PlantPot,
	Plant,
	Monster,
	Lightning,
}
# Map that assigns a complexity score to each cell type
const infinity = 1000000
const cell_complexity_score = {
	Type.Standard: 0,
	Type.Sand: 1,
	Type.Concrete: 1,
	Type.ConcreteSemiBroken: infinity,
	Type.Compressed: 2,
	Type.Balloon: 2,
	Type.Gold: 3,
	Type.Bomb: 2,
	Type.Clock: 1,
	Type.Gift: 2,
	Type.PlantPot: 1,
	Type.Plant: infinity,
	Type.Monster: 2,
	Type.Lightning: 1,
}
# A mapping of a sprite's state and where it maps to in the sprite sheet
const SpriteCoords: Dictionary[Type, Vector2i] = {
	Type.Standard: 8 * Vector2i(0,0),
	Type.Sand: 8 * Vector2i(1,0),
	Type.Gold: 8 * Vector2i(0,1),
	Type.Bomb: 8 * Vector2i(1,1),
	Type.Compressed: 8 * Vector2i(0,2),
	Type.Balloon: 8 * Vector2i(1,2),
	Type.Monster: 8 * Vector2i(3,2),
	Type.Gift: 8 * Vector2i(3,0),
	Type.Plant: 8 * Vector2i(4,1),
	Type.PlantPot: 8 * Vector2i(4,2),
	Type.Clock: 8 * Vector2i(2,0),
	Type.Concrete: 8 * Vector2i(2,1),
	Type.ConcreteSemiBroken: 8 * Vector2i(2,2),
	Type.Lightning: 8 * Vector2i(4,0),
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
	match type:
		_:
			var sprite_coords = SpriteCoords[type]
			draw_texture_rect_region(sprite_sheet, rec, Rect2(sprite_coords.x, sprite_coords.y, 8,8))

func destroy(game: TetrisGame):
	# Do effects
	match type:
		Type.Concrete:
			game.remove_at(grid_pos.x, grid_pos.y)
			game.set_at(grid_pos.x, grid_pos.y, Type.ConcreteSemiBroken)
		Type.Bomb:
			var particle_instance = explosion_particle.instantiate()
			get_parent().add_child(particle_instance)
			particle_instance.position = position
			game.remove_at(grid_pos.x, grid_pos.y)
			# Destroy all surrounding blocks
			for offset in [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)]:
				var res_grid_pos = grid_pos + offset
				var n = game.get_at(res_grid_pos.x, res_grid_pos.y)
				if n != null:
					n.destroy(game)
		Type.Clock:
			game.remove_at(grid_pos.x, grid_pos.y)
			game.remaining_time += 5
		_:
			game.remove_at(grid_pos.x, grid_pos.y)
	

	# Do scoring
	var score
	match type:
		Type.Gold:
			score = 10
		Type.Compressed:
			score = 5
			game.score_counter.add_mult(1)
		Type.Balloon:
			score = 10
			game.score_counter.add_mult(1)
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
			if tick % 20 == 0:
				game.score_counter.apply_score(1, position)
		Type.PlantPot:
			if tick % 40 == 0:
				var pos = grid_pos
				for i in range(5):
					pos += Vector2i(0, -1)
					if game.out_of_bounds(pos.x, pos.y):
						break

					var c = game.get_at(pos.x, pos.y)
					if c != null:
						if c.type != Type.Plant:
							break
					else:
						game.set_at(pos.x, pos.y, Type.Plant)
						break
		Type.Monster:
			var moved = false
			if tick % 3 == 0:
				moved = moved or game.try_move_cell(grid_pos.x, grid_pos.y, grid_pos.x, grid_pos.y + 1)
			if not moved and tick % 12 == 0:
				var possible_directions = []
				if not game.out_of_bounds(grid_pos.x - 1, grid_pos.y) and game.get_at(grid_pos.x - 1, grid_pos.y) == null:
					possible_directions.append(Vector2i(-1, 0))
				elif not game.out_of_bounds(grid_pos.x - 1, grid_pos.y - 1) and game.get_at(grid_pos.x - 1, grid_pos.y - 1) == null:
					possible_directions.append(Vector2i(-1, -1))

				if not game.out_of_bounds(grid_pos.x + 1, grid_pos.y) and game.get_at(grid_pos.x + 1, grid_pos.y) == null:
					possible_directions.append(Vector2i(1, 0))
				elif not game.out_of_bounds(grid_pos.x + 1, grid_pos.y - 1) and game.get_at(grid_pos.x + 1, grid_pos.y - 1) == null:
					possible_directions.append(Vector2i(1, -1))
				
				if possible_directions.size() > 0:
					var direction = possible_directions[randi() % possible_directions.size()]
					game.try_move_cell(grid_pos.x, grid_pos.y, grid_pos.x + direction.x, grid_pos.y + direction.y)
		Type.Gift:
			# For that bug where on-placing doesnt work
			game.remove_at(grid_pos.x, grid_pos.y)
			var non_infinite_complexity_types = []
			for _type in Type.values():
				if cell_complexity_score[_type] < infinity:
					non_infinite_complexity_types.append(_type)
			var new_type = non_infinite_complexity_types[randi() % non_infinite_complexity_types.size()]
			game.set_at(grid_pos.x, grid_pos.y, new_type)
		Type.Lightning:
			# Destroy all cells in column
			for y in range(game.HEIGHT):
				var c = game.get_at(grid_pos.x, y)
				if c != null:
					c.destroy(game)

func on_place(game: TetrisGame):
	# Called when the cell is placed
	match type:
		Type.Gift:
			game.remove_at(grid_pos.x, grid_pos.y)
			var non_infinite_complexity_types = []
			for _type in Type.values():
				if cell_complexity_score[_type] < infinity:
					non_infinite_complexity_types.append(_type)
			var new_type = non_infinite_complexity_types[randi() % non_infinite_complexity_types.size()]
			game.set_at(grid_pos.x, grid_pos.y, new_type)
