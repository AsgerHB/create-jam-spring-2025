extends Sprite2D

@onready var wiggler = $".."
@onready var game = $"../.." # Sorry!

func _process(delta: float) -> void:
	if game.hold_locked:
		visible = true
		wiggler.wiggle = false
	else:
		visible = false
		wiggler.wiggle = true
