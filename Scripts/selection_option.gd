extends Node2D
class_name SelectionOption

@export var flying_in_multiplier = 0.8 + randf_range(0, 2)
@export var rotation_rate = 4 # How quickly they rotate
@export var rotation_multiplier = 0.2 # Set to less than 1 to make them just wiggle a little.

@onready var selector:Selector = $"/root/Selector"
@onready var button:Button = $"SelectorButton"
@onready var tetriminos:Tetriminos = $"Tetriminos"

var id:int
var template:TetriminosTemplate

enum Status { WaitingToFlyIn, FlyingIn, Idle, FadingOut}

var animation_status:Status = Status.WaitingToFlyIn
var picked = false
var flying_in_progress = 0
var rotation_progress = 0
var fade_progress = 0
var rotation_offset = randi_range(0, 20); # Randomly offset rotation timing so they are not all in sync
var target:Vector2
var starting_position:Vector2

func _ready() -> void:
	target = global_position
	
	# Start in the center of the block (offset by at most 2)
	global_position = starting_position

func _process(delta: float) -> void:
	match animation_status:
		Status.WaitingToFlyIn:
			button.visible = false
			global_position = starting_position
		Status.FlyingIn:
			button.visible = false
			flying_in_progress += delta*flying_in_multiplier
			global_position = lerp(starting_position, target, flying_in_progress)
			if flying_in_progress >= 1:
				global_position = target
				animation_status = Status.Idle
				button.visible = true
		Status.Idle:
			# button.visible = true # Had to set it elsewhere
			pass
		Status.FadingOut:
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
	animation_status = Status.FadingOut
	if is_instance_valid(button):
		button.queue_free() # Remove button immediately cause the player might press it otherwise :p

func setup(templateʹ:TetriminosTemplate, idʹ:int) -> void: # U+2B9 Modifier Letter Prime. Cry about it.
	template = templateʹ
	id = idʹ
	tetriminos.setup(template)

func fly_in() -> void:
	animation_status = Status.FlyingIn
