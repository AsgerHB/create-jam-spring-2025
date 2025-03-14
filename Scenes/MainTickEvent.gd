extends Node

signal global_event(delta)

var tick_interval : float = 0.1
var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = tick_interval 
	timer.autostart = true
	timer.connect("timeout", _tick)
	print("eventmade")
	
func _tick():
	emit_signal("global_event", get_process_delta_time())
