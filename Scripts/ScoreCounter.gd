extends Node2D
class_name ScoreCounter

@onready var current_score_text:RichTextLabel = $"CurrentScore"

var current_score = 0

func apply_score(points:int, mult:int):
	current_score += points*mult
	current_score_text.text = str(current_score)
