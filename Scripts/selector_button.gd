extends Button

var tetramino

@onready var run_state:RunState = CurrentRun
@onready var selector:Selector = $"/root/Selector"
const game_prefab: PackedScene = preload("res://Scenes/Game.tscn")

func setup(value):
	tetramino = value
	#This was not required, leaving it here in case it breaks itself again
	#button_down.connect(_on_button_down)

func _on_button_down():
	#Add reward to stash
	run_state.stash.push_back(tetramino)
	
	self.queue_free()
	
	if selector.minos_to_pick > 1:
		selector.minos_to_pick -= 1
		return
	
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
