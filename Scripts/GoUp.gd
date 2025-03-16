extends RichTextLabel

@export var speed: float = 1

func _process(delta: float) -> void:
	get_parent().position.y += delta*speed
