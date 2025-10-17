##An object on which all background are located.
##
## Key Features:
## - Display grass, tribune, wall and road tiles.
## - Automatic renewal Tilemaps, Cloakrooms and Fans when player approaches.
class_name Stadium
extends Node2D


const FAN_LIMIT: int = 10
const STEP_LIMIT: int = 15 * 1

@export var cloakroom_scene: PackedScene
@export var fan_scene: PackedScene

#tilemaplayers
@onready var grass: TileMapLayer = $Grass
@onready var tribune: TileMapLayer = $Tribune
@onready var wall: TileMapLayer = $Wall
@onready var road: TileMapLayer = $Road
#entry and exit points
@onready var cloakrooms: Node2D = $Cloakrooms
#kick targets
@onready var fans: Node2D = $Fans


#shifts for each tile type
var current_offset: Dictionary
#tiles cluster sizes
var tile_to_cluster_size: Dictionary
#spacing distance between cell clusters
var tile_to_gap: Dictionary

#Player position tracking counters
var current_limit: int = STEP_LIMIT
var current_player_x_tile: int = 4


func _ready() -> void:
	init_current_offsets()
	extend_tilemaps()
	extend_tilemaps()
	
#set inital values for each tile type
func init_current_offsets() -> void:
	current_offset["tribune"] = {}
	current_offset["tribune"]["WoodLeft"] = Vector2i(20, 0)
	current_offset["tribune"]["MetalCenter"] = Vector2i(24, 0)
	current_offset["tribune"]["WoodRight"] = Vector2i(30, 0)
	current_offset["grass"] = {}
	current_offset["grass"]["Odd"] = Vector2i(18, 7)
	current_offset["grass"]["Even"] = Vector2i(21, 7)
	current_offset["wall"] = {}
	current_offset["wall"]["Odd"] = Vector2i(18, 6)
	current_offset["wall"]["Even"] = Vector2i(21, 6)
	current_offset["road"] = {}
	current_offset["road"]["Pebble"] = Vector2i(19, 0)
	
	tile_to_cluster_size["tribune"] = {}
	tile_to_cluster_size["tribune"]["WoodLeft"] = Vector2i(4, 6)
	tile_to_cluster_size["tribune"]["MetalCenter"] = Vector2i(6, 6)
	tile_to_cluster_size["tribune"]["WoodRight"] = Vector2i(4, 6)
	tile_to_cluster_size["grass"] = {}
	tile_to_cluster_size["grass"]["Odd"] = Vector2i(3, 7)
	tile_to_cluster_size["grass"]["Even"] = Vector2i(3, 7)
	tile_to_cluster_size["wall"] = {}
	tile_to_cluster_size["wall"]["Odd"] = Vector2i(3, 1)
	tile_to_cluster_size["wall"]["Even"] = Vector2i(3, 1)
	tile_to_cluster_size["road"] = {}
	tile_to_cluster_size["road"]["Pebble"] = Vector2i(1, 8)
	
	#spacing distance between cell clusters
	tile_to_gap["tribune"] = {}
	tile_to_gap["tribune"]["WoodLeft"] = 15
	tile_to_gap["tribune"]["MetalCenter"] = 15
	tile_to_gap["tribune"]["WoodRight"] = 15
	tile_to_gap["grass"] = {}
	tile_to_gap["grass"]["Odd"] = 6
	tile_to_gap["grass"]["Even"] = 6
	tile_to_gap["wall"] = {}
	tile_to_gap["wall"]["Odd"] = 6
	tile_to_gap["wall"]["Even"] = 6
	tile_to_gap["road"] = {}
	tile_to_gap["road"]["Pebble"] = 15
	
#background tiles extension
func extend_tilemaps() -> void:
	current_limit += STEP_LIMIT
	#array of possible Fan locations
	var fan_coords = []
	
	#for each tile type, drawing a cell cluster
	for terrain in tile_to_cluster_size:
		for type in tile_to_cluster_size[terrain]:
			var terrain_id = tile_to_cluster_size[terrain].keys().find(type)
			var layer = get(terrain)
			
			#tracking reaching the edge of the rendering
			while current_offset[terrain][type].x < current_limit:
				var cluster_size = tile_to_cluster_size[terrain][type]
				var coords = []
				
				#drawing a cell cluster
				for _i in cluster_size.y:
					for _j in cluster_size.x:
						var coord = Vector2i(_j, _i) + current_offset[terrain][type]
						coords.append(coord)
				
				current_offset[terrain][type].x += tile_to_gap[terrain][type]
				layer.set_cells_terrain_connect(coords, 0, terrain_id)
				
				#allocation of a second cell for Cloakroom
				if terrain == "road":
					add_cloakroom(coords[1])
				#replenishment of the array of possible locations of Fans.
				if terrain == "tribune":
					fan_coords.append_array(coords)
	
	fan_coords.shuffle()
	extend_fans(fan_coords)
	
func extend_fans(fan_coords_: Array) -> void:
	for _i in min(FAN_LIMIT, fan_coords_.size()):
		var coord = fan_coords_.pop_back()
		add_fan(coord)
	
#creating Cloakroom
func add_cloakroom(coord_: Vector2i) -> void:
	var cloakroom = cloakroom_scene.instantiate()
	cloakroom.position = road.map_to_local(coord_)
	cloakroom.stadium = self
	cloakrooms.add_child(cloakroom)
	
#creating Fan with a random face
func add_fan(coord_: Vector2i) -> void:
	var fan = fan_scene.instantiate()
	fan.position = road.map_to_local(coord_)
	fan.stadium = self
	fans.add_child(fan)
	fan.id = randi_range(1, 5)
