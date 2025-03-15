extends Node2D
class_name TetrisGame

const WIDTH: int = 10
const HEIGHT: int = 20
const CELL_SIZE: int = 32

const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")

var grid: Array = []

func _ready() -> void:
	print("AHWD")
	for row in range(HEIGHT):
		var r = []
		for col in range(WIDTH):
			r.append(null)
		grid.append(r)
	
	# TEST
	set_at(0, 0, Cell.CellType.Standard)
	set_at(0, HEIGHT-1, Cell.CellType.Standard)
	set_at(WIDTH-1, 0, Cell.CellType.Standard)

func get_at(x: int, y: int) -> Cell:
	return grid[y][x]

func set_at(x: int, y: int, type: Cell.CellType) -> Cell:
	var cur = get_at(x, y)
	if cur != null:
		return cur  # TODO: Replace?
	var cell = cell_prefab.instantiate()
	add_child(cell)
	cell.position = Vector2i(x * CELL_SIZE, y * CELL_SIZE)
	cell.type = type
	return cell

func _draw() -> void:
	var half = 0.5 * CELL_SIZE
	draw_rect(Rect2(-half, -half, WIDTH * CELL_SIZE, HEIGHT * CELL_SIZE), Color.GRAY)
