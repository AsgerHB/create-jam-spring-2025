class_name TetriminoGenerator

func tetrimino_hash(tetrimino: Array[CellTemplate]) -> int:
	var _hash = 0
	for cell in tetrimino:
		_hash ^= cell.pos.x + cell.pos.y * 100
	return _hash
'
func update_sprites(cells: Array[CellTemplate]):
	
	for cell in cells:
		for other_cell in cells:
			if cell == other_cell:
				continue;
			if cell.pos.x - other_cell.pos.x == 1: cell.neighbours["left"] = true 
			if cell.pos.x - other_cell.pos.x == -1: cell.neighbours["right"] = true 
			if cell.pos.y - other_cell.pos.y == 1: cell.neighbours["down"] = true 
			if cell.pos.y - other_cell.pos.y == -1: cell.neighbours["up"] = true 
				
				'
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
				
	if (complexity > 0 && randi() % 10 == 0):
		var oops_type
		if randi() % 2 == 0:
			oops_type = Cell.Type.Balloon # OOPS! ALL BALLOONS!
		else:
			oops_type = Cell.Type.Sand # OOPS! ALL SAND!
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
