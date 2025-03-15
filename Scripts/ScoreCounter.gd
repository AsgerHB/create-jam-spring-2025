extends Node2D
class_name ScoreCounter

@onready var current_score_text:RichTextLabel = $"CurrentScore"
@onready var current_multiplier_text:RichTextLabel = $"CurrentMultiplier"

var score_effect: PackedScene = preload("res://Prefabs/ScoreEffect.tscn")

var mult_timeout: float = 0

var current_mult = 1
var current_score = 0

func _ready() -> void:
	set_mult(current_mult)
	current_score_text.text = str(current_score)

func _process(delta: float) -> void:
	if mult_timeout < 0:
		mult_timeout = 1
		if current_mult > 1:
			set_mult(current_mult - 1)
	mult_timeout -= delta

func _spawn_score_effect(score: int, position: Vector2):
	var score_effect_instance = score_effect.instantiate()
	get_parent().add_child(score_effect_instance)
	score_effect_instance.position = position
	score_effect_instance.set_score(score)

func add_mult(mult: int):
	mult_timeout = 1
	set_mult(current_mult + 1)

func set_mult(mult: int):
	current_mult = mult
	if current_mult > 1:
		current_multiplier_text.text = "[color=red]" + str(mult) + "[/color]"
	else:
		current_multiplier_text.text = str(mult)


func apply_score(points:int, position: Vector2):
	_spawn_score_effect(points*current_mult, position)
	current_score += points*current_mult
	current_score_text.text = str(current_score)
