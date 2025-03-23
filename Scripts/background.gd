extends TileMapLayer
class_name FillableBackground

func _get_tile_offset_from_score(score):
	return Vector2i(int(clampf(score * 5, 0, 5)), 0)

func set_filled(filledness: float):
	for y in range(TetrisGame.HEIGHT):
		for x in range(TetrisGame.WIDTH):
			var a = float(y + 7) / (TetrisGame.HEIGHT + 7)
			var b = filledness
			var score = (a - b) * 3 + float((x ^ y) % 10) / 10
			set_cell(Vector2i(x, y), 1, _get_tile_offset_from_score(score))
