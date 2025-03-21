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
	[400, 90],
	[550, 90],
	[750, 90],
	[1000, 90],
	[1250, 90],
	[1500, 90],
	[1750, 90],
	[2000, 90],
	[2300, 90],
	[2600, 90],
	[2900, 90],
]

var L = TetriminosTemplate.new([
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 1, Cell.Type.Standard),
	])
	
var J = TetriminosTemplate.new([
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(-1, -1, Cell.Type.Standard),
	])
	
var T = TetriminosTemplate.new([
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
	])

var I = TetriminosTemplate.new([
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(-2, 0, Cell.Type.Standard),
	])

var S = TetriminosTemplate.new([
		CellTemplate.new(-1, -1, Cell.Type.Standard),
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
	])

var Z = TetriminosTemplate.new([
		CellTemplate.new(1, -1, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
	])

var O = TetriminosTemplate.new([
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(0, 1, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(1, 1, Cell.Type.Standard),
	])



func _init() -> void:
	var tetrimino_generator = TetriminoGenerator.new()
	stash = [ L, J, T, T, I, I, S, Z, O, O ]

func new_game():
	current_stash = stash.duplicate()
	current_stash.shuffle()
	level = 0

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
