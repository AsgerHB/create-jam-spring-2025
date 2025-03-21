extends Node2D
class_name Selector

@onready var run_state:RunState = CurrentRun

const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const button_prefab: PackedScene = preload("res://Prefabs/SelectorButton.tscn")

var generator
var tetriminos = []
var spawnedminos = []
var rotation_progress = 0
@export var rotation_rate = 4 # How quickly they rotate
@export var rotation_multiplier = 0.2 # Set to less than 1 to make them just wiggle a little.

@export var minos_to_spawn = 6
@export var minos_to_pick = 2

@export var button_y_offset = 100
@export var row_offset = 500
@export var row_spacing = 200
@export var grid_spacing = 180

#Minos are misalligned, hack to move them to the right manually
@export var mino_offset = 80

func _ready():
	generator = TetriminoGenerator.new()
	#Make some minos
	for i in minos_to_spawn:
		if run_state.level < 5:
			tetriminos.append(generator.generate_tetrimino(randi() % 3 + 3, randi() % 7))
		else:
			tetriminos.append(generator.generate_tetrimino(randi() % 5 + 3, randi() % 15))
	
	#Spawn them all
	for i in minos_to_spawn:
		
		var prefab = tetriminos_prefab.instantiate()
		var prefabButton: Button = button_prefab.instantiate()
		add_child(prefab)
		add_child(prefabButton)
		
		var current_mino = tetriminos.pop_back()
		
		prefab.setup(current_mino)
		prefabButton.setup(current_mino)
		var ypos = row_spacing
		var xpos = grid_spacing * i
		if(i % 2 == 0):
			ypos += row_offset
			xpos += grid_spacing
		prefab.position = Vector2(xpos + mino_offset, ypos)
		prefabButton.position = Vector2(xpos, ypos + button_y_offset)
		
		#For spinning game objects
		spawnedminos.push_back(prefab)

#Spinner, this is gonna perform badly, gamejam yay
func _process(delta):
	rotation_progress += delta*rotation_rate
	
	
	# The i is just to get a unique offset for each chid. 
	# Since 1 is not a divisor of π, they will rotate out of sync.
	var i = 0 
	for item in spawnedminos:
		i += 1
		item.rotation = sin(rotation_progress + i)*rotation_multiplier
		
func buttonFunc():
	print("sanity sweet sanity")
