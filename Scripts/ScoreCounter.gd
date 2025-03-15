extends Node2D
class_name ScoreCounter

@onready var current_score_text:RichTextLabel = $"CurrentScore"
@onready var current_multiplier_text:RichTextLabel = $"CurrentMultiplier"

var mult_timeout: float = 0

var current_mult = 1
var current_score = 0

func _ready() -> void:
	set_mult(current_mult)
	apply_score(0)

func _process(delta: float) -> void:
	if mult_timeout < 0:
		mult_timeout = 0
		if current_mult > 1:
			set_mult(current_mult - 1)
	mult_timeout += delta

func add_mult(mult: int):
	set_mult(current_mult + 1)

func set_mult(mult: int):
	current_mult = mult
	if current_mult > 1:
		current_multiplier_text.text = "[color=red]" + str(mult) + "[/color]"
	else:
		current_multiplier_text.text = str(mult)


func apply_score(points:int):
	current_score += points*current_mult
	current_score_text.text = str(current_score)
