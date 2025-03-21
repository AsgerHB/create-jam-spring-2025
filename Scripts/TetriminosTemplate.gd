class_name TetriminosTemplate

var cells: Array[CellTemplate] = []

func _init(cells: Array[CellTemplate]) -> void:
	self.cells = cells

# Get width of tetrimino
func get_width():
	var lower = 0
	var upper = 0
	for cell in cells:
		if cell.pos.x < lower:
			lower = cell.pos.x
		if cell.pos.x > upper:
			upper = cell.pos.x
	return upper - lower + 1
	
# Get height of tetrimino
func get_height():
	var lower = 0
	var upper = 0
	for cell in cells:
		if cell.pos.y < lower:
			lower = cell.pos.y
		if cell.pos.y > upper:
			upper = cell.pos.y
	return upper - lower + 1
