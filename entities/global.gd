extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var dict = {}


func _ready() -> void:
	if dict.keys().is_empty():
		init_arr()
		init_dict()
	
func init_arr() -> void:
	pass
	
func init_dict() -> void:
	init_direction()
	init_tile()
	
func init_tile() -> void:
	dict.tile_to_cluster_size = {}
	dict.tile_to_cluster_size["tribune"] = {}
	dict.tile_to_cluster_size["tribune"]["WoodLeft"] = Vector2i(4, 6)
	dict.tile_to_cluster_size["tribune"]["MetalCenter"] = Vector2i(6, 6)
	dict.tile_to_cluster_size["tribune"]["WoodRight"] = Vector2i(4, 6)
	dict.tile_to_cluster_size["grass"] = {}
	dict.tile_to_cluster_size["grass"]["Odd"] = Vector2i(3, 7)
	dict.tile_to_cluster_size["grass"]["Even"] = Vector2i(3, 7)
	dict.tile_to_cluster_size["wall"] = {}
	dict.tile_to_cluster_size["wall"]["Odd"] = Vector2i(3, 1)
	dict.tile_to_cluster_size["wall"]["Even"] = Vector2i(3, 1)
	dict.tile_to_cluster_size["road"] = {}
	dict.tile_to_cluster_size["road"]["Pebble"] = Vector2i(1, 8)
	
	dict.tile_to_gap = {}
	dict.tile_to_gap["tribune"] = {}
	dict.tile_to_gap["tribune"]["WoodLeft"] = 15
	dict.tile_to_gap["tribune"]["MetalCenter"] = 15
	dict.tile_to_gap["tribune"]["WoodRight"] = 15
	dict.tile_to_gap["grass"] = {}
	dict.tile_to_gap["grass"]["Odd"] = 6
	dict.tile_to_gap["grass"]["Even"] = 6
	dict.tile_to_gap["wall"] = {}
	dict.tile_to_gap["wall"]["Odd"] = 6
	dict.tile_to_gap["wall"]["Even"] = 6
	dict.tile_to_gap["road"] = {}
	dict.tile_to_gap["road"]["Pebble"] = 15
	
func init_direction() -> void:
	dict.direction = {}
	dict.direction.linear2 = [
		Vector2i( 0,-1),
		Vector2i( 1, 0),
		Vector2i( 0, 1),
		Vector2i(-1, 0)
	]
	dict.direction.diagonal = [
		Vector2i( 1,-1),
		Vector2i( 1, 1),
		Vector2i(-1, 1),
		Vector2i(-1,-1)
	]
	
	dict.direction.hybrid = []
	
	for _i in dict.direction.linear2.size():
		var direction = dict.direction.linear2[_i]
		dict.direction.hybrid.append(direction)
		direction = dict.direction.diagonal[_i]
		dict.direction.hybrid.append(direction)
	
func save(path_: String, data_): #: String
	var file = FileAccess.open(path_, FileAccess.WRITE)
	file.store_string(data_)
	
func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
	return json_object.get_data()
	
func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null
