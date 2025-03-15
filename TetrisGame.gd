extends Node2D
class_name TetrisGame

const WIDTH: int = 10
const HEIGHT: int = 20
const CELL_SIZE: int = 32

# TODO: Both of these are basically empty, maybe unnecessary
const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")
const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")

var example_tetriminos = TetriminosTemplate.new([
	CellTemplate.new(-1, 0, Cell.Type.Standard),
	CellTemplate.new(0, 0, Cell.Type.Standard),
	CellTemplate.new(1, 0, Cell.Type.Standard),
	CellTemplate.new(-1, 1, Cell.Type.Standard),
])

@export var move_interval_ticks: int = 14
@export var move_fast_interval_ticks: int = 2

var grid: Array = []
var falling_tetriminos: Tetriminos = null
var ticks_since_last_move: int = 0

var move_int 

func _ready() -> void:
	for row in range(HEIGHT):
		var r = []
		for col in range(WIDTH):
			r.append(null)
		grid.append(r)
	
	# TEST
	set_at(0, 0, Cell.Type.Standard)
	set_at(0, HEIGHT-1, Cell.Type.Standard)
	set_at(WIDTH-1, 0, Cell.Type.Standard)


func get_at(x: int, y: int) -> Cell:
	if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT:
		return null
	return grid[y][x]


func set_at(x: int, y: int, type: Cell.Type) -> Cell:
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

func get_next_tetriminos_from_deck() -> TetriminosTemplate:
	# TODO Draw from deck instead
	return example_tetriminos


func _on_tick() -> void:
	# TODO Incorporate with other tick stuff
	ticks_since_last_move += 1
	if ticks_since_last_move < move_interval_ticks:
		return
		
	ticks_since_last_move = 0
	
	# Move the falling brick - if we have any
	if falling_tetriminos == null:
		print("Spawning new falling tetriminos")
		var template = get_next_tetriminos_from_deck()
		falling_tetriminos = tetriminos_prefab.instantiate()
		add_child(falling_tetriminos)
		falling_tetriminos.setup(template)
		falling_tetriminos.position = Vector2i(WIDTH / 2, 0) * CELL_SIZE
		
		# TODO: Check if collision with existing cells -> game over
		return
	
	# TODO: Check if collision with existing cells -> place it instead
	falling_tetriminos.position.y += CELL_SIZE
