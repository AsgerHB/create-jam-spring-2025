extends Node2D
class_name Selector

enum State { ReadyToBreak, Breaking, Idle, FadeOut }

@onready var run_state:RunState = CurrentRun
@onready var pick_sound = $"Pick"
@onready var powerup_sound = $"PowerUp"
@onready var background_music = $"Tetrogue-Menu"
@onready var black_fade:Sprite2D = $"Black-fade"
@onready var level_up_text:RichTextLabel = $"LevelUpContainer/LevelUpText"
@onready var point_light:PointLight2D = $"PointLight2D"
@onready var instructions = $"InstructionsPopup"
@onready var breakable_chunk:BreakableChunk = $"BreakableChunk"
const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const selection_option_prefab: PackedScene = preload("res://Prefabs/SelectionOption.tscn")

var animation_state:State = State.ReadyToBreak
var generator
var tetriminos = []
var spawnedminos:Array[SelectionOption] = []
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
	
func spawn_minos():
	var level = run_state.level
	
	#Make some minos
	generator = TetriminoGenerator.new()
	
	# Size: We want a good chance of generating the nice size-4 pieces
	# And then we want more awkward sizes to become more common in the higher levels.
	var prob_regular_size = 0.5
	var prob_extra_standard = 0.5
	var prob_extra_type = 0.9
	var size_min = 3
	var size_max = 4
	if level >= 15:
		size_max = 7
	elif level >= 10:
		size_max = 6
		size_min = 4
	elif level >= 5:
		size_max = 5

	var complexity_min = floor(4 + level / 5.0)
	var complexity_max = floor(complexity_min + 3 + level / 3.0)
	
	for i in minos_to_spawn:
		# Size
		var size = 4
		if randf() < prob_regular_size:
			size = randi_range(size_min, size_max)
		
		# Type
		tetriminos.append(generator.generate_tetrimino(size, breakable_chunk.types))
	#Spawn them all
	for i in minos_to_spawn:
		
		var option:SelectionOption = selection_option_prefab.instantiate()
		add_child(option)
		
		var current_mino = tetriminos.pop_back()
		option.setup(current_mino, i) # Tell the button which index it is, so we know which mino was piced
		var ypos = row_spacing
		var xpos = grid_spacing * i
		if(i % 2 == 0):
			ypos += row_offset
			xpos += grid_spacing
		option.starting_position = breakable_chunk.position
		option.position = option.starting_position
		option.target = Vector2(xpos + mino_offset, ypos)
		spawnedminos.push_back(option)
	
	# Set focus neighbors for keyboard navigation.
	for i in minos_to_spawn:
		var option:SelectionOption = spawnedminos[i]
		var left = (i - 2)%minos_to_spawn
		option.button.focus_neighbor_left = spawnedminos[left].button.get_path()
		var right = (i + 2)%minos_to_spawn
		option.button.focus_neighbor_right = spawnedminos[right].button.get_path()
		
		# TODO: Also make the wrap-around correct. 
		var top = (i + 1)%minos_to_spawn
		option.button.focus_neighbor_top = spawnedminos[top].button.get_path()
		var bottom = (i - 1)%minos_to_spawn
		option.button.focus_neighbor_bottom = spawnedminos[bottom].button.get_path()

func _process(delta):
	if animation_state != State.ReadyToBreak and Input.is_key_pressed(KEY_R): # Debug: NO-COMMIT
		get_tree().change_scene_to_file("res://Scenes/Selector.tscn")
	match animation_state:
		State.ReadyToBreak:
			point_light.visible = false
			level_up_text.visible = false
			instructions.visible = true
		State.Breaking:
			point_light.visible = true
			level_up_text.visible = false
			instructions.visible = false
		State.Idle:
			point_light.visible = true
			level_up_text.visible = true
			instructions.visible = true
		State.FadeOut:
			point_light.visible = true
			background_music.volume_linear -= delta*0.5
			black_fade.modulate.a += delta
			fade_progress += delta*fade_rate

func chunk_breaking():
	animation_state = State.Breaking
	spawn_minos()

func chunk_broken():
	animation_state = State.Idle
	for option in spawnedminos:
		option.animation_status = SelectionOption.Status.FlyingIn

func register_picked(index):
	powerup_sound.pitch_scale += 0.2
	powerup_sound.play()
	if minos_to_pick > 1:
		minos_to_pick -= 1
		reassign_focus()
	else:
		for child in get_children():
			if child is SelectionOption:
				child.start_fading_out()
		animation_state = State.FadeOut
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/GetReadyScreen.tscn")

func reassign_focus() -> void:
	for option in spawnedminos:
		if !option.button.visible:
			continue
		else:
			option.button.grab_focus()
			break
