extends Node2D
class_name Tetriminos

const CELL_SIZE: int = 32

const cell_prefab = preload("res://Prefabs/Cell.tscn")

var cells: Array[Cell]
var grid_pos: Vector2i = Vector2i(0, 0)

func setup(template: TetriminosTemplate):
	assert(len(cells) == 0, "Tetriminos got setup twice")
	for ct in template.cells:
		var cell: Cell = cell_prefab.instantiate()
		add_child(cell)
		cell.position = ct.pos * CELL_SIZE
		cell.grid_pos = ct.pos
		cell.type = ct.type
		cells.append(cell)
