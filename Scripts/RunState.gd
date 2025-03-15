extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash


# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = stash.duplicate();

# All the player's tetriminos. Hard-coded to starting values
var stash: Array[TetriminosTemplate] = []
var level: int = 0
var levels = [
	[100, 90],
	[250, 90],
	[500, 90],
	[750, 90],
	[1000, 90],
	[1300, 90],
	[1750, 90],
	[2000, 90],
	[2500, 90],
	[3000, 90],
	[4000, 90],
	[7000, 90],
	[10000, 90],
]


func _init() -> void:
	var tetrimino_generator = TetriminoGenerator.new()
	for i in 20:
		var tetriminos = tetrimino_generator.generate_tetrimino(4, 0)
		stash.push_back(tetriminos)
	for i in 3:
		var tetriminos = tetrimino_generator.generate_tetrimino(5, 0)
		stash.push_back(tetriminos)

func new_game():
	current_stash = stash.duplicate()
	current_stash.shuffle()

func pop_from_stash():
	if current_stash.size() <= 0:
		current_stash = stash.duplicate()
		current_stash.shuffle()
	return current_stash.pop_back()

func get_level():
	var n = levels.size()
	if level < n:
		return levels[level]
	else:
		return [11000 + 2**(level - n), 60]

func increment_level():
	level += 1
