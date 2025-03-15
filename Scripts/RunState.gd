extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash


func new_game():
	current_stash = stash.duplicate()
	#current_stash.shuffle()

func pop_from_stash():
	if current_stash.size() > 0:
		return current_stash.pop_back()
	else:
		return null

# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = stash.duplicate();

var L = TetriminosTemplate.new([
		CellTemplate.new(-1, 0, Cell.Type.Standard),
		CellTemplate.new(0, 0, Cell.Type.Standard),
		CellTemplate.new(1, 0, Cell.Type.Standard),
		CellTemplate.new(-1, 1, Cell.Type.Standard),
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

# All the player's tetriminos. Hard-coded to starting values
var stash: Array[TetriminosTemplate] = [
	L,
	O,
	T,
	I,
	S,
	Z,
]
