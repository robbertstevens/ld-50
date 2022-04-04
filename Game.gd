extends Node2D


export (PackedScene) onready var Bomb
export (PackedScene) onready var Corner

onready var camera = $Camera
onready var player = $Player
onready var land = $TileMaps/Land
onready var water = $TileMaps/Water
onready var zeus = $Zeus

var rng = RandomNumberGenerator.new()


const EMPTY_TILE_ID = -1
const WATER_TILE_ID = 1
const LAND_TILE_ID = 0

var tile_size = 8
var center: Vector2

export (float) var radius = 4

func _ready() -> void:
    rng.randomize()

    var bounds = TileMapBounds.from_tile_map($TileMaps/Land)
    
    print(bounds.limit_top)
    print(bounds.limit_left)
    print(bounds.limit_right)
    print(bounds.limit_bottom)
    
    camera.limit_left = bounds.limit_left
    camera.limit_right = bounds.limit_right
    camera.limit_top =  bounds.limit_top
    camera.limit_bottom = bounds.limit_bottom

    center = land.get_used_rect().get_center() * tile_size
    create_debug_block(center)
    print(center)

func _physics_process(delta: float) -> void:
    camera.global_position = lerp(camera.global_position, player.global_position, 0.2)


    # Move Zeus
    zeus.global_position = rotate_around_point(zeus.global_position, center, 25 * delta)

func _on_KinematicBody2D_bomb_thrown(position, target) -> void:
    var bomb_instance = create_bomb(position, target)
    
    add_child(bomb_instance)


func _on_Bomb_explode(position) -> void:
    var hit_cell: Vector2 = land.world_to_map(position)
        
#    create_debug_block(position)

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


func create_bomb(position: Vector2, target: Vector2):
    var bomb_instance = Bomb.instance()
    bomb_instance.global_position = position
    bomb_instance.target = target
    
    bomb_instance.connect("bomb_explode", self, "_on_Bomb_explode") 
    
    return bomb_instance

func inside_circle(center: Vector2, tile: Vector2, radius: float) -> bool:
    var dx = center.x - tile.x;
    var dy = center.y - tile.y;
    var distance = sqrt(dx*dx + dy*dy);
    
    return distance <= radius;

func rotate_around_point(pos: Vector2, center: Vector2, angle: float) -> Vector2: 
    var r = angle * (PI / 180)
    
    var x = cos(r) * (pos.x - center.x) - sin(r) * (pos.y-center.y) + center.x 
    var y = sin(r) * (pos.x - center.x) + cos(r) * (pos.y-center.y) + center.y
    
    return Vector2(x, y)

func _on_Player_land_build(position) -> void:
    var tile = land.world_to_map(position)
    var cell = land.get_cellv(tile)
    
    if cell == EMPTY_TILE_ID:
        land.set_cellv(tile, LAND_TILE_ID)
        water.set_cellv(tile, EMPTY_TILE_ID)
        land.update_bitmask_area(tile)


func _on_BombTimer_timeout() -> void:    
    var land_cells = land.get_used_cells_by_id(LAND_TILE_ID)

    if land_cells.size(): 
        var target = land_cells[rng.randi_range(0, land_cells.size() - 1)]
        
        var bomb_instance = create_bomb(zeus.global_position, target * tile_size)
        
        add_child(bomb_instance)
    else:
        $BombTimer.stop()


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


func _on_Player_died() -> void:
    print("player died")
