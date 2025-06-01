extends Node2D

@onready var stats: RichTextLabel = $"/root/EndScreen/Stats"
@onready var tetrimino_container: Node2D = $"EndScreenTetriminos"
@onready var back_button:Button = $"Interactive/BackButton"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
	pass # Replace with function body.

func _ready() -> void:
	back_button.grab_focus()
	stats.text = ("You reached level [color=blue]" + str(CurrentRun.level) + "[/color]!\n" +
				  "You scored a total of [color=yellow]" + str(CurrentRun.accumulated_score) + "[/color]!\n" +
				  "Your highest score was [color=yellow]" + str(CurrentRun.highest_score) + "[/color]")
