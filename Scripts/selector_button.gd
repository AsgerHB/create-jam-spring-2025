extends Button

var tetramino

@onready var run_state:RunState = $"/root/Run"
const game_prefab: PackedScene = preload("res://Prefabs/tetris_game.tscn")

func setup(value):
	tetramino = value
	button_down.connect(_on_button_down)

func _on_button_down():
	var root = get_tree().get_root()
	#Add reward to stash
	run_state.stash.push_back(tetramino)
	
	#Pass to game by call_defer deleting entire selector node and all children
	#Make game prefab and add to root node as child
	#Requires this structure constantly
	#root
	# Game
	# Selector 
	#Where only one of them exists at any given time.
	#Game creates selector, selector creates game, the cycle of life and death continues
	var selector = get_node("/root/Run/Selector")
	var game = game_prefab.instantiate()
	root.add_child(game)
	selector.call_deferred("queue_free")
	#root.remove_child(selector) 
