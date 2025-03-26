extends Node2D

var rotation_progress = 0
@export var rotation_rate = 4 # How quickly they rotate
@export var rotation_multiplier = 0.2 # Set to less than 1 to make them just wiggle a little.

func _process(delta: float) -> void:
	rotation_progress += rotation_rate*delta
	rotation = sin(rotation_progress)*rotation_multiplier
