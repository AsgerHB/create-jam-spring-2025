extends Node2D

# Also hijacked for instructions pages


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")
	pass # Replace with function body.


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Instructions2.tscn")
	pass # Replace with function body.

func _on_next2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Instructions2.tscn")
	pass # Replace with function body.
