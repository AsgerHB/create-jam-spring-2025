extends Node2D
class_name Selector

@onready var run_state:RunState = $"/root/Run"

const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const button_prefab: PackedScene = preload("res://Prefabs/SelectorButton.tscn")

var generator
var tetriminos = []
var spawnedminos = []
var time = 0

var minos_to_spawn = 10

var button_y_offset = 100
var grid_spacing = 200

func _ready():
	print(self.get_path())
	generator = TetriminoGenerator.new()
	#Make some minos
	for i in minos_to_spawn:
		tetriminos.append(generator.generate_tetrimino(randi() % 3 + 3))
	
	#Spawn them all
	for i in minos_to_spawn:
		var prefab = tetriminos_prefab.instantiate()
		var prefabButton: Button = button_prefab.instantiate()
		add_child(prefab)
		add_child(prefabButton)
		
		var current_mino = tetriminos.pop_back()
		
		prefab.setup(current_mino)
		prefabButton.setup(current_mino)
		prefab.position = Vector2(grid_spacing * i,100)
		prefabButton.position = Vector2(grid_spacing * i,100 + button_y_offset)
		
		#For spinning game objects
		spawnedminos.push_back(prefab)

#Spinner, this is gonna perform badly, gamejam yay
func _process(delta):
	time += delta
	for item in spawnedminos:
		item.rotation = sin(time)
		
func buttonFunc():
	print("sanity sweet sanity")
