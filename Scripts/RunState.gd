extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash


# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = stash.duplicate();

# All the player's tetriminos. Hard-coded to starting values
var stash: Array[TetriminosTemplate] = []
var level: int = 0
var levels = [
	[500, 120],
	[750, 120],
	[900, 120],
	[1500, 120],
	[1800, 120],
	[2000, 120],
	[2500, 120],
	[3000, 120],
	[3500, 120],
	[4000, 120],
	[5000, 120],
	[7000, 120],
	[10000, 120],
]


func _init() -> void:
	var tetrimino_generator = TetriminoGenerator.new()
	for i in 20:
		var tetriminos = tetrimino_generator.generate_tetrimino(4, 0)
		stash.push_back(tetriminos)
	for i in 3:
		var tetriminos = tetrimino_generator.generate_tetrimino(5, 4)
		stash.push_back(tetriminos)

func new_game():
	current_stash = stash.duplicate()
	current_stash.shuffle()

func pop_from_stash():
	if current_stash.size() > 0:
		return current_stash.pop_back()
	else:
		return null

func get_level():
	return levels[level]

func increment_level():
	++level
