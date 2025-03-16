extends Node2D
class_name Selector

@onready var run_state:RunState = $"/root/Run"

const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const button_prefab: PackedScene = preload("res://Prefabs/SelectorButton.tscn")

var generator
var tetriminos = []
var spawnedminos = []
var time = 0

var minos_to_spawn = 6
var minos_to_pick = 2

var button_y_offset = 100
var row_offset = 500
var row_spacing = 200
var grid_spacing = 180

#Minos are misalligned, hack to move them to the right manually
var mino_offset = 80

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
	time += delta
	for item in spawnedminos:
		item.rotation = sin(time)
		
func buttonFunc():
	print("sanity sweet sanity")
