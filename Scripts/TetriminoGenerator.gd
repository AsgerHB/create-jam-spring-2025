class_name TetriminoGenerator

const oops_types: Array[Cell.Type] = [
	Cell.Type.Sand,
	Cell.Type.Concrete,
	Cell.Type.Compressed,
	Cell.Type.Clock,
	Cell.Type.PlantPot,
	Cell.Type.Lightning
]

func tetrimino_hash(tetrimino: Array[CellTemplate]) -> int:
	var _hash = 0
	for cell in tetrimino:
		_hash ^= cell.pos.x + cell.pos.y * 100
	return _hash
	
# Complexity controls how complex the tetromino is
func generate_tetrimino(size:int, complexity: int=0) -> TetriminosTemplate:
	var tetrimino: Array[CellTemplate] = []
	var possible_next_positions: Array[Vector2i] = [Vector2i(0, 0)]
	var used_positions: Array[Vector2i] = []
	var current_size: int = 0
	var current_complexity: int = 0

	while (current_size < size):
		# Choose random next position
		var next_position = possible_next_positions[randi() % possible_next_positions.size()]
		possible_next_positions.erase(next_position)
		used_positions.append(next_position)

		# Chooose randomly next cell type within complexity budget
		var types_in_budget: Array[Cell.Type] = []
		for type in Cell.Type.values():
			if Cell.cell_complexity_score[type] + current_complexity <= complexity:
				types_in_budget.append(type)
			else:
				types_in_budget.append(Cell.Type.Standard)
		
		var next_type = types_in_budget[randi() % types_in_budget.size()]
		current_complexity += Cell.cell_complexity_score[next_type]
		current_size += 1

		# Add cell to tetrimino
		tetrimino.append(CellTemplate.new(next_position.x, next_position.y, next_type))

		# Add next position to possible next positions
		for offset in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var new_position = next_position + offset
			if not possible_next_positions.has(new_position) and not used_positions.has(new_position):
				possible_next_positions.append(new_position)
				
	if (complexity > 0 && randi() % 8 == 0):
		print("OOPS!")
		var oops_type = oops_types[randi() % len(oops_types)]
		for t in tetrimino:
			t.type = oops_type
		
	# update_sprites(tetrimino)
	# Canonize tetrimino
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
