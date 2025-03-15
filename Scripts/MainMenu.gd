extends Node2D


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Run.tscn")
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
	pass # Replace with function body.
