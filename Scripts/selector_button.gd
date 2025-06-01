extends Button

@onready var run_state:RunState = CurrentRun
@onready var selection_option:SelectionOption = $".."
const game_prefab: PackedScene = preload("res://Scenes/Game.tscn")

func _on_button_down():
	#Add reward to stash
	run_state.stash.push_back(selection_option.template)
	selection_option.selector.register_picked(selection_option.id)
	selection_option.picked = true
	
	self.queue_free()
