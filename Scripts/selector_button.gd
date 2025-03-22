extends Button

var tetramino

@onready var run_state:RunState = CurrentRun
@onready var selector:Selector = $"/root/Selector"
var id = 0
const game_prefab: PackedScene = preload("res://Scenes/Game.tscn")

func setup(value, id):
	tetramino = value
	self.id = id
	#This was not required, leaving it here in case it breaks itself again
	#button_down.connect(_on_button_down)

func _on_button_down():
	#Add reward to stash
	run_state.stash.push_back(tetramino)
	selector.register_picked(id)
	
	self.queue_free()
	
