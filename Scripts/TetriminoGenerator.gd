class_name TetriminoGenerator

const oops_types: Array[Cell.Type] = [
	Cell.Type.Compressed,
	Cell.Type.Multiplier,
	Cell.Type.Sand,
	Cell.Type.Concrete,
	Cell.Type.Clock,
	Cell.Type.PlantPot,
	Cell.Type.Lightning
]

func tetrimino_hash(tetrimino: Array[CellTemplate]) -> int:
	var _hash = 0
	for cell in tetrimino:
		_hash ^= cell.pos.x + cell.pos.y * 100
	return _hash

func random_type_with_finite_complexity() -> Cell.Type:
	var t = Cell.Type.values().pick_random()
	while Cell.cell_complexity_score[t] == Cell.infinity:
		t = Cell.Type.values().pick_random()
	return t

# Complexity controls how complex the tetromino is
func generate_tetrimino(complexity: int) -> TetriminosTemplate:
	# Determine types in the tetrimino
	var types = []
	if randi() % 8 == 0:
		# OOOPS all same
		var t = oops_types.pick_random()
		types.append(t)
		complexity -= 2 * Cell.cell_complexity_score[t]
	else:
		# At most two types beside standard
		types.append(Cell.Type.Standard)
		types.append(random_type_with_finite_complexity())
		if randi() % complexity == 0:
			# If complexity is low we increase chance of standard (big tetris)
			types.append(Cell.Type.Standard)
		else:
			types.append(random_type_with_finite_complexity())
		for t in types:
			complexity -= Cell.cell_complexity_score[t]
	
	# Remaining complexity determines size
	var size = 3 + max(0, floor(complexity / 2.0))
	
	var tetrimino: Array[CellTemplate] = []
	var possible_next_positions: Array[Vector2i] = [Vector2i(0, 0)]
	var used_positions: Array[Vector2i] = []
	var current_size: int = 0

	while (current_size < size):
		# Choose random next position
		var next_position = possible_next_positions[randi() % possible_next_positions.size()]
		possible_next_positions.erase(next_position)
		used_positions.append(next_position)
		
		var next_type = types.pick_random()
		current_size += 1

		# Add cell to tetrimino
		tetrimino.append(CellTemplate.new(next_position.x, next_position.y, next_type))

		# Add next position to possible next positions
		for offset in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var new_position = next_position + offset
			if not possible_next_positions.has(new_position) and not used_positions.has(new_position):
				possible_next_positions.append(new_position)
	
	# Center tetrimino
	var min_corner = Vector2i()
	var max_corner = Vector2i()
	for cell in tetrimino:
		min_corner = min_corner.min(cell.pos)
		max_corner = max_corner.max(cell.pos)
	var adjust = min_corner + Vector2i(
		floor((max_corner.x - min_corner.x + 1) / 2),
		floor((max_corner.y - min_corner.y + 1) / 2)
	)
	for cell in tetrimino:
		cell.pos -= adjust
	
	# Canonize tetrimino rotation
	var min_hash = tetrimino_hash(tetrimino)
	var min_hash_tetrimino = tetrimino.duplicate()
	for i in range(3):
		# Rotate tetrimino
		for cell in tetrimino:
			cell.pos = Vector2i(cell.pos.y, -cell.pos.x)
		if tetrimino.hash() < min_hash:
			min_hash = tetrimino_hash(tetrimino)
			min_hash_tetrimino = tetrimino.duplicate()
	
	return TetriminosTemplate.new(min_hash_tetrimino)
