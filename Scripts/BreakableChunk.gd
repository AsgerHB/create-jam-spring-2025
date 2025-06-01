extends Node2D
class_name BreakableChunk

@export var width:int = 10
@export var height:int = 10
@export var layers:int = 10
@export var rotation_rate:float = 10
@export var rotation_multiplier: float = 0.01

@export var shake_time:float = 1
@export var flyaway_time:float = 3
@export var flyaway_weight:float = 1

var rotation_progress:float = 0.0
var shake_progress:float = 0
var flyaway_progress:float = 0
var broken:bool = false
var target_distance_min = 1920
var target_distance_max = target_distance_min*4
var cell_starting_points = []
var cell_targets = []

var notified_breaking = false # for debounce
var notified_broken = false # for debounce

const cell_prefab = preload("res://Prefabs/Cell.tscn")
@onready var cells_container = $"Cells"
@onready var button = $"Button"
@onready var selector:Selector = $".."
@onready var chunk_break_sound:AudioStreamPlayer = $"ChunkBreak"
@onready var chunk_breaking_sound:AudioStreamPlayer = $"ChunkBreaking"

func _ready() -> void:
	button.grab_focus()
	var x_start = -(width/2)*Cell.CELL_SIZE
	var y_start = -(height/2)*Cell.CELL_SIZE
	var x = x_start
	var y = y_start
	for k in layers: 
		for j in height:
			for i in width:
				var cell: Cell = cell_prefab.instantiate()
				cells_container.add_child(cell)
				if randi() % 2 == 0:
					cell.type = TetriminoGenerator.random_type_with_finite_complexity()
				else:
					cell.type = Cell.Type.Standard
				cell.position = Vector2(x, y)
				cell_starting_points.append(cell.position)
				
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
			flyaway_progress += delta
			for cell:Cell in cells_container.get_children():
				cell.position = lerp(cell_starting_points[i], cell_targets[i], flyaway_progress/flyaway_time)
				i += 1
			if !notified_broken:
				chunk_break_sound.play()
				notified_broken = true
				selector.chunk_broken()
		else:
			free_self_no_lag() # Async function avoid lag spike when freeing so many objects

func free_self_no_lag():
	await get_tree().create_timer(0.2).timeout # This is the only way I know to make the function async.
	self.queue_free()

func _on_button_pressed() -> void:
	button.visible = false
	broken = true
	selector.chunk_breaking()
