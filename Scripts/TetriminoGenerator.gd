class_name TetriminoGenerator

func tetrimino_hash(tetrimino: Array[CellTemplate]) -> int:
	var _hash = 0
	for cell in tetrimino:
		_hash ^= cell.pos.x + cell.pos.y * 100
	return _hash

func generate_tetrimino(size:int, types:Array[Cell.Type]) -> TetriminosTemplate:		
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
