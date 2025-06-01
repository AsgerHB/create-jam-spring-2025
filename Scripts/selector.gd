extends Node2D
class_name Selector

@onready var run_state:RunState = CurrentRun
@onready var pick_sound = $"Pick"
@onready var powerup_sound = $"PowerUp"
@onready var background_music = $"Tetrogue-Menu"
@onready var black_fade:Sprite2D = $"Black-fade"
@onready var level_up_text:RichTextLabel = $"LevelUpContainer/LevelUpText"
const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const selection_option_prefab: PackedScene = preload("res://Prefabs/SelectionOption.tscn")

var generator
var tetriminos = []
var spawnedminos = []
var picked_minos = []
var fade_out = false
var fade_rate = 2
var fade_progress = 0

@export var minos_to_spawn = 6
@export var minos_to_pick = 2

@export var row_offset = 500
@export var row_spacing = 200
@export var grid_spacing = 180

#Minos are misalligned, hack to move them to the right manually
@export var mino_offset = 80

func _ready():
	# Set "reached level ??" text
	level_up_text.text = level_up_text.text.replace("??", str(run_state.level))
	
	generator = TetriminoGenerator.new()
	#Make some minos
	var complexity_min = floor(4 + run_state.level / 5.0)
	var complexity_max = floor(complexity_min + 3 + run_state.level / 3.0)
	for i in minos_to_spawn:
		tetriminos.append(generator.generate_tetrimino(randi_range(complexity_min, complexity_max)))
	
	#Spawn them all
	for i in minos_to_spawn:
		
		var option = selection_option_prefab.instantiate()
		add_child(option)
		
		var current_mino = tetriminos.pop_back()
		option.setup(current_mino, i) # Tell the button which index it is, so we know which mino was piced
		var ypos = row_spacing
		var xpos = grid_spacing * i
		if(i % 2 == 0):
			ypos += row_offset
			xpos += grid_spacing
		option.position = Vector2(xpos + mino_offset, ypos)
		

#Spinner, this is gonna perform badly, gamejam yay
func _process(delta):
	if fade_out:
		background_music.volume_linear -= delta*0.5
		black_fade.modulate.a += delta
		fade_progress += delta*fade_rate

func register_picked(index):
	picked_minos.append(index)
	powerup_sound.pitch_scale += 0.2
	powerup_sound.play()
	if minos_to_pick > 1:
		minos_to_pick -= 1
	else:
		for child in get_children():
			if child is SelectionOption:
				child.start_fading_out()
		fade_out = true
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/GetReadyScreen.tscn")
