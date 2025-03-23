extends Node2D

const explosion_particle = preload("res://Prefabs/explosion_particle.tscn")

var origin: Vector2i
var zone: Rect2i
var cell_size: int

var next_positions = []
var done_positions = []

func setup(origin: Vector2i, zone: Rect2i, cell_size: int):
	self.origin = origin
	self.zone = zone
	self.cell_size = cell_size
	next_positions.append(origin)
	_on_spread_timer_timeout()


func spread_explosion():
	var next_next_positions = []
	for next in next_positions:
		if not zone.has_point(next) or next in done_positions:
			continue
		done_positions.append(next)
		var ex = explosion_particle.instantiate()
		add_child(ex)
		ex.position = next * cell_size
		for delta in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor = next + delta
			if zone.has_point(next) and neighbor not in done_positions:
				next_next_positions.append(neighbor)
	next_positions = next_next_positions


func _on_spread_timer_timeout() -> void:
	spread_explosion()
	spread_explosion()
