extends TileMapLayer
class_name Map

func to_array(width, height):
	# Build dictionary maping from atlas coordinates to Type.
	# The Cell class already has a map from sprite pixel position to Type.
	# So we just convert the pixel position to atlas coordinates: From (32, 64) to (2, 4)
	# And save the result.
	var atlas_coords_to_type: Dictionary[Vector2i, Cell.Type] = {}
	for key:Cell.Type in Cell.SpriteCoords:
		var atlas_coords = Cell.SpriteCoords[key]/Cell.CELL_SIZE
		atlas_coords_to_type[atlas_coords] = key
	
	var result:Array[Array] = []
	for row in width:
		result.append([])
		for col in height:
			var coords:Vector2i = get_cell_atlas_coords(Vector2i(row, col))
			if coords == Vector2i(-1, -1):
				result[row].append(null)
			else:
				result[row].append(atlas_coords_to_type[coords])
	return result
