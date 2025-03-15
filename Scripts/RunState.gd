extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash

func _init() -> void:
	var tetrimino_generator = TetriminoGenerator.new()
	for i in 10:
		var tetriminos = tetrimino_generator.generate_tetrimino(4)
		stash.push_back(tetriminos)
	for i in 3:
		var tetriminos = tetrimino_generator.generate_tetrimino(5)
		stash.push_back(tetriminos)

func new_game():
	current_stash = stash.duplicate()
	current_stash.shuffle()

func pop_from_stash():
	if current_stash.size() > 0:
		return current_stash.pop_back()
	else:
		return null

# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = stash.duplicate();

# All the player's tetriminos. Hard-coded to starting values
var stash: Array[TetriminosTemplate] = []
