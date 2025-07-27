extends Node2D

@export var max_falling:int = 15
@export var spawn_delay_min = 1
@export var spawn_delay_max = 6
@export var fall_speed_min = 30
@export var fall_speed_max = 100
@export var rotation_speed_min = -0.3
@export var rotation_speed_max =  0.3

@onready var this = $"."
@onready var tetriminos_animated = preload("res://Prefabs/TetriminosAnimated.tscn")
@onready var generator:TetriminoGenerator = TetriminoGenerator.new()

const min_starting_x = 0
const max_starting_x = 1920
const preferred_x_distance = 300
const starting_y = -400
const y_max = 1080 + 800

var spawn_delay = 0
var previous_x = 0

func _process(delta: float) -> void:
	spawn_delay -= delta
	if get_child_count() < max_falling && spawn_delay < 0:
		spawn_new()
		spawn_delay = randf_range(spawn_delay_min, spawn_delay_max)
		
func spawn_new():
	var minos:TetriminosAnimated = tetriminos_animated.instantiate()
	var size = randi_range(3, 5)
	if randf() > 0.5:
		size = 4
	var template:TetriminosTemplate = generator.generate_tetrimino(size, [Cell.Type.Standard])
	for cell:CellTemplate in template.cells:
		cell.type = Cell.Type.Standard
	minos.setup(template)
	this.add_child(minos)
	
	# speed
	minos.falling_speed = randf_range(fall_speed_min, fall_speed_max)
	minos.rotation_speed = randf_range(rotation_speed_min, rotation_speed_max)
	
	# x, y
	var x = randf_range(min_starting_x, max_starting_x)
	
	# Try to not spawn the next one in the same place
	for i in 3:
		if abs(x - previous_x) > preferred_x_distance:
			break
		x = randf_range(min_starting_x, max_starting_x)
	previous_x = x
	
	var y = starting_y
	minos.position = Vector2(x, y)
	minos.y_max = y_max
