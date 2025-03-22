extends Node2D

@onready var stats:RichTextLabel = $"Stats"

func _ready() -> void:
	var level_info = CurrentRun.get_level()
	var score_target = level_info[0]
	var time = level_info[1]
	var minutes = floor(time/60)
	var seconds = time - minutes*60
	stats.text = ("[color=blue]Level\t" + str(CurrentRun.level) + "[/color]\n" +
				  "Target\t[color=yellow]" + str(score_target) + "[/color]\n" +
				  "Time \t[color=blue]" + str(minutes) + ":" + str(seconds) + "[/color]")
	

func _on_begin_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
