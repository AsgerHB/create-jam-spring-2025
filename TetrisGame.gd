extends Node2D
class_name TetrisGame

const WIDTH: int = 10
const HEIGHT: int = 20
const CELL_SIZE: int = 32

# TODO: Both of these are basically empty, maybe unnecessary
const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")
const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const selector_prefab: PackedScene = preload("res://Prefabs/Selector.tscn")

@onready var run_state:RunState = $"/root/Run"
@onready var goal_value:RichTextLabel = $"Goal Value"
@onready var remaining_time_label:RichTextLabel = $"Remaining Time"
@onready var status_label:RichTextLabel = $"Status Label"
@onready var score_counter:ScoreCounter = $"ScoreCounter"

@export var remaining_time: float = 50
@export var score_goal: int = 100
var tick_number: int = 0 # The current tick count
@export var move_interval_ticks: int = 14
@export var move_fast_interval_ticks: int = 2
@export var move_sideways_interval_ticks: int = 3

var pause: bool = false

var grid: Array = []
var falling_tetriminos: Tetriminos = null
var ticks_since_last_down_move: int = 0
var ticks_since_last_sideways_move: int = 0

var move_int 

var root

func _ready() -> void:
	root = get_tree().get_root()
	print(self.get_path())
	for row in range(HEIGHT):
		var r = []
		for col in range(WIDTH):
			r.append(null)
		grid.append(r)
	
	run_state.new_game()
	var lvl = run_state.get_level()
	score_goal = lvl[0]
	remaining_time = lvl[1]
	
	goal_value.text = str(score_goal)
	#win()

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
	cell.grid_pos = Vector2i(x, y)
	cell.type = type
	grid[y][x] = cell
	return cell


# See also destroy_at
func remove_at(x: int, y: int):
	var c = get_at(x, y)
	if c != null:
		grid[y][x] = null
		c.queue_free()


# Similar to remove_at but triggers the cell's on_destory effect (possibly preventing destruction)
func destroy_at(x: int, y: int):
	var c = get_at(x, y)
	if c != null:
		# Pass self in case destruction has side effects (e.g. bomb)
		c.destroy(self)


# See also try_move_cell.
# Destination must be empty.
func move_cell(from_x: int, from_y: int, to_x: int, to_y: int):
	var c: Cell = get_at(from_x, from_y)
	if c == null:
		return
	assert(get_at(to_x, to_y) == null, "Destination must be empty")
	grid[from_y][from_x] = null
	c.grid_pos = Vector2i(to_x, to_y)
	c.position = c.grid_pos * CELL_SIZE
	grid[to_y][to_x] = c


# Similar to move_cell but triggers the cell's on_move effect (possibly preventing the move).
func try_move_cell(from_x: int, from_y: int, to_x: int, to_y: int) -> bool:
	var c = get_at(from_x, from_y)
	if c == null || not get_at(to_x, to_y) == null || out_of_bounds(to_x, to_y):
		return false
	# Pass self in case movement has side effects
	if c.on_move(self, to_x, to_y):
		move_cell(from_x, from_y, to_x, to_y)
		return true
	return false


func shift_above_cells_down(x: int, y: int):
	var c = get_at(x, y)
	if c != null:
		return
	for from_y in range(y - 1, -1, -1):
		var to_y = from_y + 1
		if get_at(x, from_y) != null && not try_move_cell(x, from_y, x, to_y):
			# A cell refused to move, skip the rest
			return


func _draw() -> void:
	# Background
	var half = 0.5 * CELL_SIZE
	draw_rect(Rect2(-half, -half, WIDTH * CELL_SIZE, HEIGHT * CELL_SIZE), Color.GRAY)


func get_next_tetriminos_from_deck() -> TetriminosTemplate:
	var next = run_state.pop_from_stash()
	if next == null:
		dead()
	return next

func _process(delta):
	if pause:
		return
	if Input.is_action_just_pressed("ui_right"):
		if try_move_falling_tetriminos_x(1):
			ticks_since_last_sideways_move = 0
	elif Input.is_action_just_pressed("ui_left"):
		if try_move_falling_tetriminos_x(-1):
			ticks_since_last_sideways_move = 0
	elif Input.is_action_just_pressed("ui_down"):
		if try_move_falling_tetriminos_down():
			ticks_since_last_down_move = 0
	elif Input.is_action_just_pressed("ui_up"):
		try_rotate_falling_tetriminos()
	
	if remaining_time > 1:
		remaining_time -= delta
	else:
		remaining_time -= delta / 3 # Artificially extend the last second
	remaining_time_label.set_time(remaining_time)
	
	if score_counter.current_score >= score_goal:
		win()
	
	if remaining_time < 0:
		dead()


func _on_tick() -> void:
	if pause:
		return
	tick_number += 1

	# Call on_tick for all cells in order of their type
	var cell_type_to_cells: Dictionary[Cell.Type, Array] = {}
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var cell = get_at(x, y)
			if cell != null:
				if not cell.type in cell_type_to_cells:
					cell_type_to_cells[cell.type] = []
				cell_type_to_cells[cell.type].append(cell)
	
	for cell_type in Cell.Type.values():
		if cell_type in cell_type_to_cells:
			for cell in cell_type_to_cells[cell_type]:
				cell.on_tick(self, tick_number)
	
	# Move sideways if key is held
	ticks_since_last_sideways_move += 1
	if falling_tetriminos != null && ticks_since_last_sideways_move >= move_sideways_interval_ticks:
		if Input.is_action_pressed("ui_right"):
			if try_move_falling_tetriminos_x(1):
				ticks_since_last_sideways_move = 0
		elif Input.is_action_pressed("ui_left"):
			if try_move_falling_tetriminos_x(-1):
				ticks_since_last_sideways_move = 0
		elif Input.is_key_pressed(KEY_W):
			win()
	
	if Input.is_action_pressed("slam_down"):
		# Hard drop
		if falling_tetriminos != null:
			while try_move_falling_tetriminos_down():
				pass
			ticks_since_last_down_move = 0
			return
	else:
		# Move downwards regularly, but faster if key is held
		ticks_since_last_down_move += 1
		var interval = move_fast_interval_ticks if Input.is_action_pressed("ui_down") else move_interval_ticks
		if ticks_since_last_down_move < interval:
			return
		
		ticks_since_last_down_move = 0
			
		if falling_tetriminos != null:
			# Move down
			try_move_falling_tetriminos_down()
			return

	
	# If we do not have a falling tetriminos, spawn one instead
	print("Spawning new falling tetriminos")
	var template = get_next_tetriminos_from_deck()
	falling_tetriminos = tetriminos_prefab.instantiate()
	add_child(falling_tetriminos)
	falling_tetriminos.setup(template)
	var grid_pos = Vector2i(WIDTH / 2, 0)
	falling_tetriminos.position = grid_pos * CELL_SIZE
	falling_tetriminos.grid_pos = grid_pos
	

	# If we immediately collide with existing cells -> game over
	if does_falling_tetriminos_collide():
		dead()


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


func try_rotate_falling_tetriminos() -> bool:
	if falling_tetriminos == null:
		return false
	rotate_falling_tetriminos(true)
	if not does_falling_tetriminos_collide():
		return true
	
	# Colliding! Try to avoid collision by moving left or right
	try_move_falling_tetriminos_x(1)
	if not does_falling_tetriminos_collide():
		return true
	try_move_falling_tetriminos_x(-1)
	if not does_falling_tetriminos_collide():
		return true
	
	# Rotation failed, undo
	rotate_falling_tetriminos(false)
	return false


func rotate_falling_tetriminos(counter_clockwise: bool) -> void:
	if counter_clockwise:
		for cell in falling_tetriminos.cells:
			cell.grid_pos = Vector2i(-cell.grid_pos.y, cell.grid_pos.x)
			cell.position = cell.grid_pos * CELL_SIZE
	else:
		for cell in falling_tetriminos.cells:
			cell.grid_pos = Vector2i(cell.grid_pos.y, -cell.grid_pos.x)
			cell.position = cell.grid_pos * CELL_SIZE


func does_falling_tetriminos_collide() -> bool:
	for cell in falling_tetriminos.cells:
		var res_grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
		if out_of_bounds(res_grid_pos.x, res_grid_pos.y):
			return true
		if get_at(res_grid_pos.x, res_grid_pos.y) != null:
			return true
	
	return false


func place_falling_tetriminos() -> void:
	for cell in falling_tetriminos.cells:
		var res_grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
		set_at(res_grid_pos.x, res_grid_pos.y, cell.type)
	falling_tetriminos.queue_free()
	falling_tetriminos = null
	
	clear_full_rows()


func clear_full_rows():
	var rows_to_clear = []
	for y in range(HEIGHT):
		var do_clear = true
		for x in range(WIDTH):
			if get_at(x, y) == null:
				do_clear = false
				continue
		if do_clear:
			rows_to_clear.append(y)
	
	# Destroy all tiles in the cleared rows, applying mult
	var first = true
	for y in rows_to_clear:
		if !first:
			score_counter.add_mult(1)
		first = false
		for x in range(WIDTH):
			var c: Cell = get_at(x, y)
			if c == null:
				pass
			destroy_at(x, y)
		
	# Then shift cells down (affects resolution order)
	for y in rows_to_clear:
		for x in range(WIDTH):
			shift_above_cells_down(x, y)
	

func win():
	run_state.increment_level()
	status_label.text = "[color=green]Winner! :-)[/color]"
	pause = true
	await get_tree().create_timer(4.0).timeout
	var run = $"/root/Run"
	var game = $"/root/Run/Game"
	var selector = selector_prefab.instantiate()
	run.add_child(selector)
	game.call_deferred("queue_free")
	
	#get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
	

func dead():
	status_label.text = "[color=red]DIED :'([/color]"
	pause = true
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
