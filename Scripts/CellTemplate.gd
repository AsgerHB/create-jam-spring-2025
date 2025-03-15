class_name CellTemplate

var pos: Vector2i
var type: Cell.Type

func _init(x: int, y: int, type: Cell.Type) -> void:
	self.pos = Vector2i(x, y)
	self.type = type
