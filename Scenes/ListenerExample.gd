extends Node

func _ready():
	MainTickEvent.global_event.connect(exampleConnection)
	
func exampleConnection():
	print("this is working!")
	
