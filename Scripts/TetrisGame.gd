extends Node2D
class_name TetrisGame

const WIDTH: int = 10
const HEIGHT: int = 20
const CELL_SIZE: int = 32

# TODO: Both of these are basically empty, maybe unnecessary
const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")
const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const selector_prefab: PackedScene = preload("res://Scenes/Selector.tscn")

@onready var run_state:RunState = CurrentRun
@onready var goal_value:RichTextLabel = $"Goal Value"
@onready var remaining_time_label:RichTextLabel = $"Remaining Time"
@onready var status_label:RichTextLabel = $"Status Label"
@onready var score_counter:ScoreCounter = $"ScoreCounter"
@onready var background:FillableBackground = $"background" 

@onready var move_sound:AudioStreamPlayer = $"Sounds/Move"
@onready var spin_sound:AudioStreamPlayer = $"Sounds/Spin"
@onready var smash_sound:AudioStreamPlayer = $"Sounds/Smash"
@onready var clear_sound:AudioStreamPlayer = $"Sounds/Clear"
@onready var win_sound:AudioStreamPlayer = $"Sounds/NextLevel"
@onready var background_music:AudioStreamPlayer = $"Tetrogue-Main"

@export var remaining_time: float = 50
@export var max_time: float = 50
@export var score_goal: int = 100
var tick_number: int = 0 # The current tick count
@export var move_interval_ticks: int = 14
@export var move_fast_interval_ticks: int = 2
@export var move_sideways_interval_ticks: int = 2

var pause: bool = false
var died: bool = false

var smash_next: bool = false

var grid: Array = []
var falling_tetriminos: Tetriminos = null
var ticks_since_last_down_move: int = 0
var ticks_since_last_sideways_move: int = 0

var queued_line_clears = []

var move_int 

var root

func _ready() -> void:
	root = get_tree().get_root()
	score_counter.set_level(run_state.level)
	for row in range(HEIGHT):
		var r = []
		for col in range(WIDTH):
			r.append(null)
		grid.append(r)
	
	run_state.new_game()
	var lvl = run_state.get_level()
	score_goal = lvl[0]
	remaining_time = lvl[1]
	max_time = remaining_time
	remaining_time_label.set_max_time(max_time)
	
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


func shift_cells_down_range(x: int, min_y: int, max_y: int):
	var c = get_at(x, max_y)
	if c != null:
		return
	for from_y in range(max_y - 1, max(-1, min_y - 1), -1):
		var to_y = from_y + 1
		move_cell(x, from_y, x, to_y)


func swap(x1: int, y1: int, x2: int, y2: int):
	var fst = get_at(x1, y1)
	var snd = get_at(x2, y2)
	if fst == null:
		move_cell(x2, y2, x1, y1)
		return
	if snd == null:
		move_cell(x1, y1, x2, y2)
		return
	grid[y1][x1] = snd
	snd.grid_pos = Vector2i(x1, y1)
	snd.position = snd.grid_pos * CELL_SIZE
	grid[y2][x2] = fst
	fst.grid_pos = Vector2i(x2, y2)
	fst.position = fst.grid_pos * CELL_SIZE


func queue_line_clear(y: int):
	if y < 0 || y >= HEIGHT:
		return
	queued_line_clears.append(y)


func _draw() -> void:
	# Background
	if falling_tetriminos != null:
		var min_y_cells: Dictionary = {}
		for cell in falling_tetriminos.cells:
			if min_y_cells.has(cell.grid_pos.x):
				min_y_cells[cell.grid_pos.x] = min(cell.grid_pos.y, min_y_cells[cell.grid_pos.x])
			else:
				min_y_cells[cell.grid_pos.x] = cell.grid_pos.y
				
		for x in min_y_cells:
			var grid_pos = falling_tetriminos.grid_pos + Vector2i(x, min_y_cells[x])
			var r = Rect2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE, CELL_SIZE, (HEIGHT - grid_pos.y) * CELL_SIZE)
			draw_rect(r, Color.WHITE * 0.6)


func get_next_tetriminos_from_deck() -> TetriminosTemplate:
	var next = run_state.pop_from_stash()
	if next == null:
		dead()
	return next

func _process(delta):
	queue_redraw()
	if pause:
		if died:
			background_music.pitch_scale -= delta/2
		else:
			background_music.volume_linear -= delta*0.5
		return
	if Input.is_action_just_pressed("slam_down"):
		smash_sound.play()
		smash_next = true
	if Input.is_action_just_pressed("ui_right"):
		move_sound.play()
		if try_move_falling_tetriminos_x(1):
			ticks_since_last_sideways_move = -6
	elif Input.is_action_just_pressed("ui_left"):
		move_sound.play()
		if try_move_falling_tetriminos_x(-1):
			ticks_since_last_sideways_move = -6
	elif Input.is_action_just_pressed("ui_down"):
		if try_move_falling_tetriminos_down():
			ticks_since_last_down_move = 0
	elif Input.is_action_just_pressed("ui_up"):
		spin_sound.play()
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
	
	background.set_filled(remaining_time / max_time)
	
	clear_full_rows()

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
	
	if smash_next:
		smash_next = false
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
		if get_at(res_grid_pos.x, res_grid_pos.y) == null:
			dead()
		else:
			get_at(res_grid_pos.x, res_grid_pos.y).on_place(self)
	falling_tetriminos.queue_free()
	falling_tetriminos = null


func clear_full_rows():
	for y in range(HEIGHT):
		var do_clear = true
		for x in range(WIDTH):
			if get_at(x, y) == null:
				do_clear = false
				continue
		if do_clear:
			queued_line_clears.append(y)
	
	if len(queued_line_clears) > 0:
		score_counter.bump_streak()
		clear_sound.play()
	
	var cleared_lines = []
	
	# Destroy all tiles in the cleared rows, applying mult
	var first = true
	while len(queued_line_clears) > 0:
		# NOTE: More lines may be queued by cells during this loop, e.g. by bombs
		var y = queued_line_clears.pop_front()
		if y in cleared_lines:
			continue  # Do not double clear
		cleared_lines.append(y)
		if !first:
			score_counter.add_mult(1)
		first = false
		for x in range(WIDTH):
			var c: Cell = get_at(x, y)
			if c == null:
				pass
			destroy_at(x, y)
		
	# Then shift cells down (affects resolution order)
	cleared_lines.sort()
	for y in cleared_lines:
		for x in range(WIDTH):
			shift_above_cells_down(x, y)
	
	queued_line_clears.clear()
	

func win():
	run_state.register_score(score_counter.current_score)
	run_state.increment_level()
	status_label.text = "[color=green]Winner! :-)[/color]"
	pause = true
	win_sound.play()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Selector.tscn")

func dead():
	run_state.register_score(score_counter.current_score)
	status_label.text = "[color=red]DIED :'([/color]"
	pause = true
	died = true
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/EndScreen.tscn")
