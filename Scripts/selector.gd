extends Node2D
class_name Selector

@onready var run_state:RunState = CurrentRun
@onready var pick_sound = $"Pick"
@onready var powerup_sound = $"PowerUp"

const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const button_prefab: PackedScene = preload("res://Prefabs/SelectorButton.tscn")

var generator
var tetriminos = []
var spawnedminos = []
var picked_minos = []
var rotation_progress = 0
var fade_out = false
var fade_rate = 2
var fade_progress = 0
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
	var complexity_min = floor(4 + run_state.level / 5.0)
	var complexity_max = floor(complexity_min + 3 + run_state.level / 3.0)
	for i in minos_to_spawn:
		tetriminos.append(generator.generate_tetrimino(randi_range(complexity_min, complexity_max)))
	
	#Spawn them all
	for i in minos_to_spawn:
		
		var prefab = tetriminos_prefab.instantiate()
		var prefabButton: Button = button_prefab.instantiate()
		add_child(prefab)
		add_child(prefabButton)
		
		var current_mino = tetriminos.pop_back()
		
		prefab.setup(current_mino)
		prefabButton.setup(current_mino, i) # Tell the button which index it is, so we know which mino was piced
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
	if fade_out:
		fade_progress += delta*fade_rate
		var i = 0
		var size = max(0, 1 - fade_progress)
		for item in spawnedminos:
			if i in picked_minos:
				item.scale = Vector2(1 + fade_progress/5, 1 + fade_progress/5)
				i += 1
				continue
			item.scale = Vector2(size, size)
			i += 1
	rotation_progress += delta*rotation_rate
	
	# The i is just to get a unique offset for each chid. 
	# Since 1 is not a divisor of π, they will rotate out of sync.
	var i = 0 
	for item in spawnedminos:
		if i in picked_minos:
			item.rotation = 0
			i += 1
			continue
		item.rotation = sin(rotation_progress + i)*rotation_multiplier
		i += 1
		
func buttonFunc():
	print("sanity sweet sanity")

func register_picked(index):
	picked_minos.append(index)
	powerup_sound.pitch_scale += 0.2
	powerup_sound.play()
	if minos_to_pick > 1:
		minos_to_pick -= 1
	else:
		for child in get_children():
			if child is Button:
				child.queue_free()
		fade_out = true
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
