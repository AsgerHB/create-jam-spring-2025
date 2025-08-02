extends Node2D
class_name LevelOption

enum RewardType { Chunk, Modify, }

@onready var map:Map = $"Map Transform/Map"
@onready var chunk = $"Chunk"
@onready var modify = $"Modify"
var reward_type:RewardType = RewardType.Chunk

func initialize(reward_type_:RewardType, new_map:Map):
	var map_parent = map.get_parent()
	print(map_parent)
	add_child(new_map)
	new_map.reparent(map_parent)
	new_map.position = map.position
	new_map.scale = map.scale
	map.queue_free()
	
	reward_type = reward_type_
	match reward_type:
		RewardType.Chunk:
			chunk.visible = true
			modify.visible = false
		RewardType.Modify:
			chunk.visible = false
			modify.visible = true

func _ready() -> void:
	initialize([RewardType.Chunk, RewardType.Modify].pick_random(), MapSelector.get_random_map(0.5))
