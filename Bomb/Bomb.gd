extends Node2D


signal bomb_explode(position)


export (float) var radius = 4


onready var Corner = preload('res://Shared/Corner.tscn')
onready var state_manager = $StateManager


enum States {
    Flying,
    Exploding,
}


var start: Vector2
var target: Vector2
var count = 0

func _ready() -> void:
    start = global_position
    
    var state_fn = {
        States.Flying: funcref(self, "_flying_state"),
        States.Exploding: funcref(self, "_exploding_state"),
    }
    
    state_manager.init(States, state_fn, States.Flying)


func _physics_process(delta: float) -> void:
    state_manager.physics_process(delta)


# https://gamedev.stackexchange.com/a/157644
func _flying_state(delta: float) -> int:
    if count > 1:
        return States.Exploding
        
    count += 1 * delta
    
    var p0 = start
    var p1 = start + (target - start) / 2 + Vector2.UP * 46 
    var p2 = target
    
    var m1 = lerp(p0, p1, count)
    var m2 = lerp(p1, p2, count)
    
    var new_pos = lerp(m1, m2, count)
    
    global_position = new_pos
    
    return States.Flying


func _exploding_state(delta: float) -> int:
    emit_signal('bomb_explode', global_position)
    
    queue_free()
    
    return -1
    

#func _on_Area2D_body_entered(body: Node) -> void:
#    if body is TileMap and body.name=="Land":
#        var hit_cell: Vector2 = body.world_to_map(global_position)
#
##        create_debug_block(global_position)
#
#        var tile_size = 8
#
#        var top_left = hit_cell - Vector2.ONE * radius
#        var bottom_right = hit_cell + Vector2.ONE * radius + Vector2.ONE 
#
##        create_debug_block(Vector2(top_left.x, top_left.y)) # TL
##        create_debug_block(Vector2(bottom_right.x, top_left.y)) # TR
##        create_debug_block(Vector2(top_left.x, bottom_right.y)) # BL
##        create_debug_block(Vector2(bottom_right.x, bottom_right.y)) # BR
#
#        for y in range(top_left.y, bottom_right.y):
#            for x in range(top_left.x, bottom_right.x):
#                var coord = Vector2(x, y)
#                if (inside_circle(hit_cell, coord, radius)):
#                    create_debug_block(coord * tile_size)
#                    body.set_cellv(coord, -1)
#
#        body.update_bitmask_region()



