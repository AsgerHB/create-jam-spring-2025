extends Node2D
class_name ScoreCounter

@onready var goal_text:RichTextLabel = $"Goal Value"
@onready var current_score_text:RichTextLabel = $"CurrentScore"
@onready var current_multiplier_text:RichTextLabel = $"CurrentMultiplier"
@onready var progress:Sprite2D = $"Bar/Progress"
@onready var progress_width = progress.scale.x
@onready var score_goal = CurrentRun.get_level()[0]

var score_effect: PackedScene = preload("res://Prefabs/ScoreEffect.tscn")

const MULT_DECREASE_RATE = 1.0/5.0
const STREAK_DECREASE_RATE = 1.0/5.0

var mult_timeout: float = 0
var streak_timeout: float = 0

var current_mult = 1
var current_score = 0

func _ready() -> void:
	progress.scale.x = 0
	set_mult(current_mult)
	goal_text.text = str(score_goal)
	current_score_text.text = str(current_score)

func _process(delta: float) -> void:
	# Progress Bar
	var current_progress = (float(current_score)/float(score_goal))*progress_width
	if progress.scale.x != current_progress:
		progress.scale.x = min(progress.scale.x + 1*delta, current_progress, progress_width)
		progress.scale.x = max(0.005, progress.scale.x)
	
	progress.modulate.h += 0.2*delta
	progress.modulate.s = max(progress.scale.x/progress_width - 0.3, 0)
	
	# Mult
	if mult_timeout < 0:
		mult_timeout = 1
		if current_mult > 1:
			set_mult(current_mult - 1)
	mult_timeout -= delta * MULT_DECREASE_RATE
	streak_timeout -= delta * STREAK_DECREASE_RATE

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
		current_multiplier_text.text = "[color=red]x" + str(mult) + "[/color]"
	else:
		current_multiplier_text.text = "x" + str(mult)


func bump_streak():
	if streak_timeout > 0:
		add_mult(1)
	streak_timeout = 1


func apply_score(points: int, position: Vector2):
	_spawn_score_effect(points*current_mult, position)
	current_score += points*current_mult
	current_score_text.text = str(current_score)
