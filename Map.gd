extends Node2D

onready var land = $Land
onready var water = $Water

func _ready() -> void:
    var land_rect = land.get_used_rect()
    var land_tiles = land.get_used_cells()
    
    var top_left = land_rect.position - Vector2(10,10)
    var bottom_right = land_rect.end + Vector2(10,10)
    
    
    for y in range(top_left.y, bottom_right.y):
        for x in range(top_left.x, bottom_right.x):
            var coord = Vector2(x, y)
            
            if not land_tiles.has(coord):
                water.set_cellv(coord, 1)

    water.update_bitmask_region()
