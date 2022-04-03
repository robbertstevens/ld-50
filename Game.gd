extends Node2D


export (PackedScene) onready var Bomb
export (PackedScene) onready var Corner

onready var camera = $Camera
onready var player = $Player
onready var land = $TileMaps/Land
onready var water = $TileMaps/Water

var EMPTY_TILE_ID = -1
var WATER_TILE_ID = 1
var LAND_TILE_ID = 0

export (float) var radius = 4

func _physics_process(delta: float) -> void:
    camera.global_position = player.global_position
    
    var bounds = TileMapBounds.from_tile_map($TileMaps/Land)
    camera.limit_left = bounds.limit_left
    camera.limit_right = bounds.limit_right
    camera.limit_top =  bounds.limit_top
    camera.limit_bottom = bounds.limit_bottom

func _on_KinematicBody2D_bomb_thrown(position, target) -> void:
    var bomb_instance = Bomb.instance()
    bomb_instance.global_position = position
    bomb_instance.target = target
    
    bomb_instance.connect("bomb_explode", self, "_on_Bomb_explode")
    
    add_child(bomb_instance)


func _on_Bomb_explode(position) -> void:
    var hit_cell: Vector2 = land.world_to_map(position)
        
#    create_debug_block(position)
        
    var tile_size = 8
    
    var top_left = hit_cell - Vector2.ONE * radius
    var bottom_right = hit_cell + Vector2.ONE * radius + Vector2.ONE 
        
#    create_debug_block(Vector2(top_left.x, top_left.y) * tile_size) # TL
#    create_debug_block(Vector2(bottom_right.x, top_left.y) * tile_size) # TR
#    create_debug_block(Vector2(top_left.x, bottom_right.y) * tile_size) # BL
#    create_debug_block(Vector2(bottom_right.x, bottom_right.y) * tile_size) # BR
        
    for y in range(top_left.y, bottom_right.y):
        for x in range(top_left.x, bottom_right.x):
            var coord = Vector2(x, y)
            
            if not inside_circle(hit_cell, coord, radius):
                continue
            
            if land.get_cellv(coord) == LAND_TILE_ID:
#                create_debug_block(coord * tile_size + Vector2(4,4))
                land.set_cellv(coord, EMPTY_TILE_ID)
                water.set_cellv(coord, WATER_TILE_ID)
    
    land.update_bitmask_region(top_left, bottom_right)
    water.update_bitmask_region(top_left, bottom_right)


func create_debug_block(position: Vector2) -> void:
    var c_i = Corner.instance()
    c_i.global_position = position
    add_child(c_i)


func inside_circle(center: Vector2, tile: Vector2, radius: float) -> bool:
    var dx = center.x - tile.x;
    var dy = center.y - tile.y;
    var distance = sqrt(dx*dx + dy*dy);
    
    return distance <= radius;


func _on_Player_land_build(position) -> void:
    var tile = land.world_to_map(position)
    var cell = land.get_cellv(tile)
    
    if cell == EMPTY_TILE_ID:
        land.set_cellv(tile, LAND_TILE_ID)
        water.set_cellv(tile, EMPTY_TILE_ID)
        land.update_bitmask_area(tile)


class TileMapBounds:
    var limit_left
    var limit_right
    var limit_top
    var limit_bottom
    
    static func from_tile_map(tile_map: TileMap) -> TileMapBounds:
        var map_limits = tile_map.get_used_rect()
        var map_cellsize = tile_map.cell_size
        var bounds = TileMapBounds.new()
        
        bounds.limit_left = map_limits.position.x * map_cellsize.x
        bounds.limit_right = map_limits.end.x * map_cellsize.x
        bounds.limit_top = map_limits.position.y * map_cellsize.y
        bounds.limit_bottom = map_limits.end.y * map_cellsize.y
        
        return bounds
