class_name Stadium
extends Node2D


@export var cloakroom_scene: PackedScene

@onready var grass: TileMapLayer = $Grass
@onready var tribune: TileMapLayer = $Tribune
@onready var wall: TileMapLayer = $Wall
@onready var road: TileMapLayer = $Road
@onready var cloakrooms: Node2D = $Cloakrooms


var step_limit: int = 15 * 1
var current_limit: int = step_limit
var current_offset: Dictionary
var current_player_x_tile: int = 4


func _ready() -> void:
	init_current_offsets()
	extend_tilemaps()
	extend_tilemaps()
	
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
	
func extend_tilemaps() -> void:
	current_limit += step_limit
	
	for terrain in Global.dict.tile_to_cluster_size:
		for type in Global.dict.tile_to_cluster_size[terrain]:
			var terrain_id = Global.dict.tile_to_cluster_size[terrain].keys().find(type)
			var layer = get(terrain)
			
			while current_offset[terrain][type].x < current_limit:
				var cluster_size = Global.dict.tile_to_cluster_size[terrain][type]
				var coords = []
				
				for _i in cluster_size.y:
					for _j in cluster_size.x:
						var coord = Vector2i(_j, _i) + current_offset[terrain][type]
						coords.append(coord)
				
				current_offset[terrain][type].x += Global.dict.tile_to_gap[terrain][type]
				layer.set_cells_terrain_connect(coords, 0, terrain_id)
				
				if terrain == "road":
					add_cloakroom(coords[1])
	
func add_cloakroom(coord_: Vector2i) -> void:
	var cloakroom = cloakroom_scene.instantiate()
	cloakroom.position = road.map_to_local(coord_)
	cloakroom.stadium = self
	cloakrooms.add_child(cloakroom)
