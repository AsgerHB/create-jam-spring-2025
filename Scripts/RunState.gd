extends Node2D
class_name RunState

# Script to contain player status such as level, lives, and tetrimino stash


# The player's stash, minus all the ones that have already been put in play.
var current_stash: Array[TetriminosTemplate] = stash.duplicate();

# All the player's tetriminos. Hard-coded to starting values
var stash: Array[TetriminosTemplate] = []
var level: int = 0
var accumulated_score = 0
var highest_score = 0

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
	reset()

func reset():
	# var tetrimino_generator = TetriminoGenerator.new()
	stash = [ L, J, T, T, I, I, S, Z, O, O ]
	level = 0
	accumulated_score = 0
	highest_score = 0

func new_game():
	current_stash = stash.duplicate()
	current_stash.shuffle()

func pop_from_stash():
	if current_stash.size() <= 0:
		current_stash = stash.duplicate()
		current_stash.shuffle()
	return current_stash.pop_back()

func get_level():
	const levels = [
		[100, 90],
		[250, 90],
		[400, 90],
		[550, 90],
		[750, 90],
	]
	if level < levels.size():
		return levels[level]
	else:
		# Increase goal quadratically from now
		var n = level - levels.size()
		return [5*n**2 + 250*n + 1000, 90]

func increment_level():
	level += 1

func register_score(score):
	accumulated_score += score
	if score > highest_score:
		highest_score = score
