extends Node2D
class_name SelectionOption

@export var rotation_rate = 4 # How quickly they rotate
@export var rotation_multiplier = 0.2 # Set to less than 1 to make them just wiggle a little.
@export var fading_out = false # animation flag

@onready var selector:Selector = $"/root/Selector"
@onready var button:Button = $"SelectorButton"
@onready var tetriminos:Tetriminos = $"Tetriminos"

var id:int
var template:TetriminosTemplate

var picked = false
var rotation_progress = 0
var fade_progress = 0
var rotation_offset = randi_range(0, 20); # Randomly offset rotation timing so they are not all in sync

func _process(delta: float) -> void:
	if fading_out:
		fade_progress += delta
		if picked:
			tetriminos.scale = Vector2(1 + fade_progress/5, 1 + fade_progress/5)
		else:
			var size = max(0, 1 - fade_progress)
			tetriminos.scale = Vector2(size, size)
	if picked:
		tetriminos.rotation = 0
	else:
		rotation_progress += delta*rotation_rate
		tetriminos.rotation = sin(rotation_progress + rotation_offset)*rotation_multiplier

func start_fading_out() -> void:
	fading_out = true
	if is_instance_valid(button):
		button.queue_free() # Remove button immediately cause the player might press it otherwise :p

func setup(templateʹ:TetriminosTemplate, idʹ:int) -> void: # U+2B9 Modifier Letter Prime. Cry about it.
	template = templateʹ
	id = idʹ
	tetriminos.setup(template)
