extends Node2D
class_name Tetriminos

const CELL_SIZE: int = 32

const cell_prefab = preload("res://Prefabs/Cell.tscn")

var template: TetriminosTemplate = null
var cells: Array[Cell]
var grid_pos: Vector2i = Vector2i(0, 0)

func setup(templateʹ: TetriminosTemplate):
	template = templateʹ
	if templateʹ == null: # After running out of tetriminos, it still tries to spawn the last one
		return
		
	cells = []
	
	for n in get_children():
		remove_child(n)
		n.queue_free() 
		
	for ct in template.cells:
		var cell: Cell = cell_prefab.instantiate()
		add_child(cell)
		cell.position = ct.pos * CELL_SIZE
		cell.grid_pos = ct.pos
		cell.type = ct.type
		cells.append(cell)
