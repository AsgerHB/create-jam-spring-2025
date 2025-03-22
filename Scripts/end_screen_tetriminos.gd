extends Node2D
class_name EndScreenTetriminos
@export var show_every:int = 1
@export var show_offset:int = 0
@export var scroll_speed = 1 # Rate at which to scroll tetriminos
@export var reset_at = 1920 # Position after which to reset to
@onready var initial_position = transform.x
var rotation_counter = 0 # For wiggling the tetriminos
@export var rotation_rate = 4 # How quickly they rotate
@export var rotation_multiplier = 0.2 # Set to less than 1 to make them just wiggle a little.

const CELL_SIZE: int = 32
@export var tetrimino_spacing = CELL_SIZE*3

const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")

func _ready() -> void:
	# Spawn the thangs
	var next = Vector2(0, 0)
	var i = 0
	for t in CurrentRun.stash:
		i += 1
		if (i + show_offset) % show_every != 0:
			continue
		var tetrimino = tetriminos_prefab.instantiate()
		add_child(tetrimino)
		tetrimino.setup(t)
		tetrimino.position = next
		var w = t.get_width()
		next.x += w*CELL_SIZE + tetrimino_spacing
		
	# Move initial position so it starts by only showing the last tetrimino
	var furthest_child_x = 0
	for child in get_children():
		if child.position.x > furthest_child_x:
			furthest_child_x = child.position.x
	
	initial_position = -furthest_child_x
	position.x = initial_position
	
func _process(delta: float) -> void:
	# Scroll accross screen
	position.x += scroll_speed*delta
	if position.x > reset_at:
		position.x = initial_position
	
	rotation_counter += delta*rotation_rate
	
	# The i is just to get a unique offset for each chid. 
	# Since 1 is not a divisor of π, they will rotate out of sync.
	var i = 0 
	for child in get_children():
		i += 1
		child.rotation = sin(rotation_counter + i)*rotation_multiplier
