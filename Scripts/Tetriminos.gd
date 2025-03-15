extends Node2D
class_name Tetriminos

const CELL_SIZE: int = 32

const cell_prefab = preload("res://Prefabs/Cell.tscn")

var cells: Array[Cell]

func setup(template: TetriminosTemplate):
	for ct in template.cells:
		var cell: Cell = cell_prefab.instantiate()
		add_child(cell)
		cell.position = ct.pos * CELL_SIZE
		cell.type = ct.type
