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


func out_of_bounds(x: int, y: int) -> bool:
	# NOTE: There is no lower bound on y axis (upwards)
	return x < 0 || x >= WIDTH || y >= HEIGHT

func get_at(x: int, y: int) -> Cell:
	if out_of_bounds(x, y) || y < 0:
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
	grid[y][x] = cell
	return cell


func _draw() -> void:
	var half = 0.5 * CELL_SIZE
	draw_rect(Rect2(-half, -half, WIDTH * CELL_SIZE, HEIGHT * CELL_SIZE), Color.GRAY)

func get_next_tetriminos_from_deck() -> TetriminosTemplate:
	# TODO Draw from deck instead
	return example_tetriminos


func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		try_move_falling_tetriminos_x(1)
	elif Input.is_action_just_pressed("ui_left"):
		try_move_falling_tetriminos_x(-1)
	elif Input.is_action_just_pressed("ui_down"):
		try_move_falling_tetriminos_down()


func _on_tick() -> void:
	# TODO Incorporate with other tick stuff
	ticks_since_last_move += 1
	if ticks_since_last_move < move_interval_ticks:
		return
		
	ticks_since_last_move = 0
	
	# If we do not have a falling tetriminos, spawn one instead
	if falling_tetriminos == null:
		print("Spawning new falling tetriminos")
		var template = get_next_tetriminos_from_deck()
		falling_tetriminos = tetriminos_prefab.instantiate()
		add_child(falling_tetriminos)
		falling_tetriminos.setup(template)
		var grid_pos = Vector2i(WIDTH / 2, 0)
		falling_tetriminos.position = grid_pos * CELL_SIZE
		falling_tetriminos.grid_pos = grid_pos
		
		# TODO: Check if collision with existing cells -> game over
		return
	
	# Move down
	try_move_falling_tetriminos_down()


func try_move_falling_tetriminos_x(delta: int) -> bool:
	if falling_tetriminos == null:
		return false
	falling_tetriminos.grid_pos.x += delta
	falling_tetriminos.position.x += delta * CELL_SIZE
	if does_falling_tetriminos_collide():
		# Undo move
		falling_tetriminos.grid_pos.x -= delta
		falling_tetriminos.position.x -= delta * CELL_SIZE
		return false
	return true


# Returns true if it moved; false if landed OR if null
func try_move_falling_tetriminos_down() -> bool:
	if falling_tetriminos == null:
		return false
	falling_tetriminos.grid_pos.y += 1
	falling_tetriminos.position.y += CELL_SIZE
	if does_falling_tetriminos_collide():
		# Undo move and place instead
		falling_tetriminos.grid_pos.y -= 1
		falling_tetriminos.position.y -= CELL_SIZE
		place_falling_tetriminos()
	return true


func does_falling_tetriminos_collide() -> bool:
	for cell in falling_tetriminos.cells:
		var res_grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
		if out_of_bounds(res_grid_pos.x, res_grid_pos.y):
			return true
		if get_at(res_grid_pos.x, res_grid_pos.y) != null:
			return true
	
	return false


func place_falling_tetriminos() -> void:
	# TODO Add cells to grid
	for cell in falling_tetriminos.cells:
		var res_grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
		set_at(res_grid_pos.x, res_grid_pos.y, cell.type)
	falling_tetriminos.queue_free()
	falling_tetriminos = null
