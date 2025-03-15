extends Node2D
class_name ScoreCounter

const MULT_DECREASE_INTERVAL = 4 * 20  # Every 4 seconds

@onready var current_score_text: RichTextLabel = $"CurrentScore"
@onready var current_mult_text: RichTextLabel = $"CurrentMult"

var current_score = 0
var current_mult = 1

var ticks_till_next_mult_dec = 0

func apply_score(points:int, mult:int):
	current_mult += mult
	current_score += points * current_mult
	current_score_text.text = str(current_score)
	current_mult_text.text = "x" + str(current_mult)


func on_tick():
	if current_mult == 1:
		ticks_till_next_mult_dec = MULT_DECREASE_INTERVAL
	else:
		ticks_till_next_mult_dec -= 1
		if ticks_till_next_mult_dec <= 0:
			current_mult -= 1
