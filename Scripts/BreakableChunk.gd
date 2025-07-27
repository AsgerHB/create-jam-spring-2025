extends Node2D
class_name BreakableChunk


@export var re_rolls = 3

@export var width:int = 10
@export var height:int = 10
@export var layers:int = 1
@export var rotation_rate:float = 10
@export var rotation_multiplier: float = 0.01

@export var shake_time:float = 1
@export var flyaway_time:float = 3
@export var flyaway_speed:float = 0.6

var rotation_progress:float = 0.0
var shake_progress:float = 0
var flyaway_progress:float = 0
var broken:bool = false
var target_distance_min = 1920
var target_distance_max = target_distance_min*5
var cell_starting_points = []
var cell_targets = []

var notified_breaking = false # for debounce
var notified_broken = false # for debounce

const cell_prefab = preload("res://Prefabs/Cell.tscn")
const cell_occluder_prefab = preload("res://Prefabs/CellOccluder.tscn")
@onready var cells_container = $"Cells"
@onready var break_button:Button = $"Break"
@onready var re_roll_button:Button = $"Re-roll"
@onready var re_roll_button_text_template = re_roll_button.text
@onready var selector:Selector = $".."
@onready var chunk_break_sound:AudioStreamPlayer = $"ChunkBreak"
@onready var chunk_breaking_sound:AudioStreamPlayer = $"ChunkBreaking"
var types:Array[Cell.Type]

func _ready() -> void:
	update_re_roll_text()
	break_button.focus_neighbor_right = re_roll_button.get_path()
	break_button.focus_neighbor_left = re_roll_button.get_path()
	re_roll_button.focus_neighbor_right = break_button.get_path()
	re_roll_button.focus_neighbor_left = break_button.get_path()
	break_button.grab_focus()
	
	roll_chunk()

func roll_chunk():
	# Clean up if this has been called before
	for cell in cells_container.get_children():
		cell.queue_free()
		
	var chunk_generator = ChunkGenerator.new()
	types = chunk_generator.generate_chunk()
	var x_start = -(width/2)*Cell.CELL_SIZE
	var y_start = -(height/2)*Cell.CELL_SIZE
	var x = x_start
	var y = y_start
	for k in layers: 
		for j in height:
			for i in width:
				var cell: Cell = cell_prefab.instantiate()
				cells_container.add_child(cell)
				cell.type = types.pick_random()
				cell.position = Vector2(x, y)
				cell_starting_points.append(cell.position)
				
				# Add occluder
				var cell_occluder = cell_occluder_prefab.instantiate()
				cell.add_child(cell_occluder)
				
				# Make sure lightning has a background cause it looks weird otherwise.
				if cell.type == Cell.Type.Lightning:
					var cellʹ: Cell = cell_prefab.instantiate()
					cell.add_child(cellʹ)
					cellʹ.type = Cell.Type.Standard
					cellʹ.show_behind_parent = true
				
				# Compute the position the cell flies to when the chunk is broken.
				var angle = randf()*PI*2
				var target_distance = randf()*(target_distance_max - target_distance_min) + target_distance_min
				cell_targets.append(Vector2(sin(angle)*target_distance, cos(angle)*target_distance))
				
				x += Cell.CELL_SIZE
			y += Cell.CELL_SIZE
			x = x_start
		x = x_start
		y = y_start

func _process(delta):
	if !broken:
		rotation_progress += delta*rotation_rate
		cells_container.rotation = sin(rotation_progress)*rotation_multiplier
	else:
		if shake_time > shake_progress:
			if !notified_breaking:
				notified_breaking = true
				chunk_breaking_sound.play()
			cells_container.rotation = 0
			shake_progress += delta
			for cell:Cell in cells_container.get_children():
				cell.position += Vector2(randf() - 0.5, randf() - 0.5)
		elif flyaway_time > flyaway_progress:
			cells_container.rotation = 0
			var i = 0
			flyaway_progress += delta*flyaway_speed
			for cell:Cell in cells_container.get_children():
				cell.position = lerp(cell_starting_points[i], cell_targets[i], flyaway_progress/flyaway_time)
				i += 1
			if !notified_broken:
				chunk_break_sound.play()
				notified_broken = true
				selector.chunk_broken()
		else:
			free_self_no_lag() # Async function avoid lag spike when freeing so many objects (Not sure if this works)

func free_self_no_lag():
	await get_tree().create_timer(0.2).timeout # This is the only way I know to make the function async.
	self.queue_free()

func _on_break_button_pressed() -> void:
	break_button.visible = false
	broken = true
	selector.chunk_breaking()

func _on_re_roll_button_pressed() -> void:
	re_rolls -= 1
	roll_chunk()
	rotation_rate += 5
	if re_rolls < 1:
		re_roll_button.visible = false
		break_button.grab_focus()
	else:
		update_re_roll_text()
	
func update_re_roll_text():
	re_roll_button.text = re_roll_button_text_template.replace("?", str(re_rolls))
