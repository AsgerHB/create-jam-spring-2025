extends Node2D
class_name Cell

@onready var lightning_sound:AudioStreamPlayer = $"../Sounds/Lightning"
@onready var explosion_sound:AudioStreamPlayer = $"../Sounds/Explosion"

const SPRITE_SIZE = 32
const CELL_SIZE: int = 32

enum Type {
	Standard,
	Compressed,
	Multiplier,
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
	Mole,
	Anvil,
}

# Types that do not "occur natturally" but only as a result of other cells.
# E.g. plants grow from pots and should never spawn on their own.
const non_natural_types = [ Type.ConcreteSemiBroken, Type.Plant ]

# A mapping of a sprite's state and where it maps to in the sprite sheet
const SpriteCoords: Dictionary[Type, Vector2i] = {
	Type.Standard: SPRITE_SIZE * Vector2i(0,0),
	Type.Compressed: SPRITE_SIZE * Vector2i(5,1),
	Type.Multiplier: SPRITE_SIZE * Vector2i(0,2),
	Type.Sand: SPRITE_SIZE * Vector2i(1,0),
	Type.Gold: SPRITE_SIZE * Vector2i(0,1),
	Type.Bomb: SPRITE_SIZE * Vector2i(1,1),
	Type.Balloon: SPRITE_SIZE * Vector2i(1,2),
	Type.Monster: SPRITE_SIZE * Vector2i(3,2),
	Type.Gift: SPRITE_SIZE * Vector2i(3,0),
	Type.Plant: SPRITE_SIZE * Vector2i(4,1),
	Type.PlantPot: SPRITE_SIZE * Vector2i(4,2),
	Type.Clock: SPRITE_SIZE * Vector2i(2,0),
	Type.Concrete: SPRITE_SIZE * Vector2i(2,1),
	Type.ConcreteSemiBroken: SPRITE_SIZE * Vector2i(2,2),
	Type.Lightning: SPRITE_SIZE * Vector2i(4,0),
	Type.Mole: SPRITE_SIZE * Vector2i(5,0),
	Type.Anvil: SPRITE_SIZE * Vector2i(3,1),
}

@export var type: Type = Type.Standard;
@export var sprite_sheet: Texture2D:
	set(value):
		sprite_sheet = value
		queue_redraw()
@export var silhouettes: Texture2D
const explosion_particle: PackedScene = preload("res://Prefabs/Explosion.tscn")
const lightning_effect: PackedScene = preload("res://Prefabs/LightningEffect.tscn")
const time_effect: PackedScene = preload("res://Prefabs/TimeEffect.tscn")

# NOTE: Local coord if in falling tetriminos
var grid_pos: Vector2i

func _draw() -> void:
	const rec = Rect2(0, 0, CELL_SIZE, CELL_SIZE)
	match type:
		_:
			var sprite_coords = SpriteCoords[type]
			draw_texture_rect_region(sprite_sheet, rec, Rect2(sprite_coords.x, sprite_coords.y, SPRITE_SIZE,SPRITE_SIZE))

func destroy(game: TetrisGame):
	# Do effects
	match type:
		Type.Concrete:
			game.remove_at(grid_pos.x, grid_pos.y)
			game.set_at(grid_pos.x, grid_pos.y, Type.ConcreteSemiBroken)
		Type.Bomb:
			var particle_instance = explosion_particle.instantiate()
			get_parent().add_child(particle_instance)
			particle_instance.setup(grid_pos, Rect2i(0, grid_pos.y - 1, 10, 3), CELL_SIZE)
			game.remove_at(grid_pos.x, grid_pos.y)
			game.queue_line_clear(grid_pos.y - 1)
			game.queue_line_clear(grid_pos.y)
			game.queue_line_clear(grid_pos.y + 1)
			
			# Play sound
			if not explosion_sound.playing:
				explosion_sound.play()
		Type.Clock:
			var time_effect_instance = time_effect.instantiate()
			get_parent().add_child(time_effect_instance)
			time_effect_instance.position = position
			game.remove_at(grid_pos.x, grid_pos.y)
			game.remaining_time += 5
		_:
			game.remove_at(grid_pos.x, grid_pos.y)
	

	# Do scoring
	var score
	match type:
		Type.Monster:
			score = 20
		Type.Mole:
			score = 15
		Type.Concrete:
			score = 10
		Type.ConcreteSemiBroken:
			score = 10
		Type.Compressed:
			score = 20
		Type.Multiplier:
			score = 0
			game.score_counter.add_mult(1)
		Type.Balloon:
			score = 5
			game.score_counter.add_mult(2)
		Type.Anvil:
			score = 0
		_:
			score = 5
	game.score_counter.apply_score(score, grid_pos * CELL_SIZE)

	return true

# Get a random types that "occurs natturally."
# E.g. plants grow from pots and should never spawn on their own.
static func random_special_type() -> Type:
	var types = Type.values()
	var result = Type.Standard
	while non_natural_types.has(result) or result == Type.Standard:
		result = types[randi_range(0, types.size() - 1)]
	return result

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
				if grid_pos.y == 4:
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
			if tick % 5 == 2:
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
			var new_type = random_special_type()
			game.set_at(grid_pos.x, grid_pos.y, new_type)
		Type.Lightning:
			# Lightning effect
			var eff = lightning_effect.instantiate()
			get_parent().add_child(eff)
			eff.position = position + Vector2(0, (game.HEIGHT - grid_pos.y - 1) * CELL_SIZE)
			
			# Play sound
			if not lightning_sound.playing:
				lightning_sound.play()
			
			# Destroy all cells in column
			for y in range(game.HEIGHT):
				var c = game.get_at(grid_pos.x, y)
				if c != null:
					c.destroy(game)
		Type.Mole:
			if tick % 75 == 0:
				# Swap with a random adjacent cell
				var dir = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)][randi() % 4]
				var target = grid_pos + dir
				if game.get_at(target.x, target.y) != null:
					game.swap(grid_pos.x, grid_pos.y, target.x, target.y)
		Type.Anvil:
			if tick % 3 == 1:
				for y in range(grid_pos.y, game.HEIGHT):
					if game.get_at(grid_pos.x, y) == null:
						game.shift_cells_down_range(grid_pos.x, grid_pos.y, y)
						break

func on_place(game: TetrisGame):
	# Called when the cell is placed
	match type:
		Type.Gift:
			pass
			#game.remove_at(grid_pos.x, grid_pos.y)
			#var non_infinite_complexity_types = []
			#var new_type = random_special_type()
			#game.set_at(grid_pos.x, grid_pos.y, new_type)
