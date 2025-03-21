extends Node2D
class_name EndScreenTetriminos
@export var scroll_speed = 1 # Rate at which to scroll tetriminos
@export var reset_at = 1920 # Position after which to reset to
@onready var initial_position = transform.x
var rotation_counter = 0 # For wiggling the tetriminos
@export var rotation_rate = 4 # How quickly they rotate
@export var rotation_multiplier = 0.2 # Set to less than 1 to make them just wiggle a little.

func initialize() -> void:
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
