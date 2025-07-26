extends Node
class_name MapSelector

static var empty = preload("res://Prefabs/Maps/empty.tscn")

# Tip: You can select-and-drag new maps to an empty line, to get their paths.
static var maps:Array[PackedScene] = [
		preload("res://Prefabs/Maps/pyramid.tscn"),
		preload("res://Prefabs/Maps/balloons.tscn"),
		preload("res://Prefabs/Maps/checker.tscn"),
		preload("res://Prefabs/Maps/clock.tscn"),
		preload("res://Prefabs/Maps/concrete1.tscn"),
		preload("res://Prefabs/Maps/concrete2.tscn"),
		preload("res://Prefabs/Maps/concrete3.tscn"),
		preload("res://Prefabs/Maps/concrete4.tscn"),
		preload("res://Prefabs/Maps/cube.tscn"),
		preload("res://Prefabs/Maps/diamond.tscn"),
		preload("res://Prefabs/Maps/funnel.tscn"),
		preload("res://Prefabs/Maps/mole.tscn"),
		preload("res://Prefabs/Maps/monster_cage.tscn"),
		preload("res://Prefabs/Maps/monster_mash.tscn"),
		preload("res://Prefabs/Maps/mult.tscn"),
		preload("res://Prefabs/Maps/plant1.tscn"),
		preload("res://Prefabs/Maps/plant2.tscn"),
		preload("res://Prefabs/Maps/pyramid.tscn"),
		preload("res://Prefabs/Maps/sand.tscn"),
		preload("res://Prefabs/Maps/wedge.tscn"),
	]

static func get_random_map(probability_empty) -> Map:
	if randf() < probability_empty:
		return empty.instantiate()
	else:
		return maps[randi_range(0, maps.size() - 1)].instantiate()
