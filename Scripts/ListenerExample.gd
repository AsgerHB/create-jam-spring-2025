extends Node

func _ready():
	MainTickEvent.global_event.connect(exampleConnection)
	
	
func exampleConnection(delta):
	#print("this is working!" + str(delta))
	pass
	
