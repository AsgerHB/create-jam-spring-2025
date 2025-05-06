extends Node2D

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

const cell_prefab = preload("res://Prefabs/Cell.tscn")
@onready var cells_container = $"Cells"

func _ready() -> void:
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
		cells_container.rotation = 0
		if shake_time > shake_progress:
			shake_progress += delta
			for cell:Cell in cells_container.get_children():
				cell.position += Vector2(randf() - 0.5, randf() - 0.5)
		if shake_time <= shake_progress and flyaway_time > flyaway_progress:
			var i = 0
			flyaway_progress += delta
			print(flyaway_progress/flyaway_time)
			for cell:Cell in cells_container.get_children():
				cell.position = lerp(cell_starting_points[i], cell_targets[i], flyaway_progress/flyaway_time)
				i += 1


func _on_button_pressed() -> void:
	broken = true
