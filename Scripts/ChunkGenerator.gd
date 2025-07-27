extends Node
class_name ChunkGenerator

const oops_types: Array[Cell.Type] = [
	Cell.Type.Compressed,
	Cell.Type.Multiplier,
	Cell.Type.Sand,
	Cell.Type.Concrete,
	Cell.Type.Clock,
	Cell.Type.PlantPot,
	Cell.Type.Lightning
]

const standard = Cell.Type.Standard

func rand() -> Cell.Type:
	return Cell.random_special_type()

func generate_chunk() -> Array[Cell.Type]:
	var level = CurrentRun.level
	
	if level >= 5 and randf() < 0.1: # Chance of "OOPS! All X!" effect, for X in oops_types
		return [oops_types.pick_random()]
	
	if level <= 10:
		var result:Array[Cell.Type] = [ standard, standard, standard, rand() ]
		if randf() <= 0.5:
			result.append(rand())
		return result
	elif level <= 15:
		return [ standard, standard, rand(), rand() ]
	elif level <= 20:
		return [ standard, standard, rand(), rand(), rand() ]
	elif level <= 25:
		return [ rand(), rand() ]
	else:
		var result:Array[Cell.Type] = []
		for i in 4:
			if randf() < 0.5:
				result.append(standard)
			else:
				result.append(rand())
		return result
