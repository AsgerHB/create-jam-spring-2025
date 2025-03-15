extends Node2D

var rigid_body: RigidBody2D
var label: Label
const time_alive: float = 2.0
var time_left_alive: float = time_alive

func _ready() -> void:
	rigid_body = $RigidBody2D
	label = $RigidBody2D/Label
	rigid_body.apply_impulse(Vector2(randf_range(-100., 100.), randf_range(0, 0)), Vector2(0, 0))


func set_score(score: int):
	label.text = "+" + str(score)
	

func _process(delta: float) -> void:
	time_left_alive -= delta
	if time_left_alive < 0:
		queue_free()
		return
	
	label.modulate.a = time_left_alive / time_alive
