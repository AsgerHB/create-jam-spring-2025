extends Node

signal global_event(delta) 

var tick_interval : float = 0.1
var timer : Timer


func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = tick_interval 
	timer.autostart = true
	timer.timeout.connect(_tick)
	timer.start() #This was required
	
func _tick():
	emit_signal("global_event", get_process_delta_time()) #Sending out delta time for now
