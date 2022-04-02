extends Node2D

var Corner = preload('res://Shared/Corner.tscn')

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
    $Area2D/CollisionShape2D.disabled = false
    
    return States.Exploding


func _on_Area2D_body_entered(body: Node) -> void:
    if body is TileMap:
        print($Area2D/CollisionShape2D.shape)
        var hit_cell: Vector2 = body.world_to_map(global_position)
        
        var c_i = Corner.instance()
        c_i.global_position = global_position # (hit_cell * 16) - Vector2(-8,-8)
        get_tree().root.add_child(c_i)
        
        var radius = 1
        
        var top_left = global_position - Vector2.ONE * radius * 16
        var bottom_right = global_position + Vector2.ONE * radius * 16
        
        c_i = Corner.instance()
        c_i.global_position = Vector2(top_left.x, top_left.y) # TL
        get_tree().root.add_child(c_i)
        
        c_i = Corner.instance()
        c_i.global_position = Vector2(bottom_right.x, top_left.y) # TR
        get_tree().root.add_child(c_i)
        
        c_i = Corner.instance()
        c_i.global_position = Vector2(top_left.x, bottom_right.y) # BL
        get_tree().root.add_child(c_i)
        
        c_i = Corner.instance()
        c_i.global_position = Vector2(bottom_right.x, bottom_right.y) # BR
        get_tree().root.add_child(c_i)
        
        for y in range(top_left.y, bottom_right.y):
            for x in range(top_left.x, bottom_right.x):
                var coord = Vector2(x, y) / 16
                print(coord)
                if (inside_circle(hit_cell, coord, radius)):
                    body.set_cellv(coord.floor(), 1)
        
#        var cells = [
#            Vector2(hit_cell.x - 1, hit_cell.y - 1),
#            Vector2(hit_cell.x - 1, hit_cell.y - 0),
#            Vector2(hit_cell.x - 1, hit_cell.y + 1),
#            Vector2(hit_cell.x - 0, hit_cell.y - 1),
#            Vector2(hit_cell.x - 0, hit_cell.y - 0),
#            Vector2(hit_cell.x - 0, hit_cell.y + 1),
#            Vector2(hit_cell.x + 1, hit_cell.y - 1),
#            Vector2(hit_cell.x + 1, hit_cell.y - 0),
#            Vector2(hit_cell.x + 1, hit_cell.y + 1),
#        ]
#
#        for cell in cells: 
#            var corners = [
#                ((cell * 16) - Vector2(-8,-8)) + Vector2(+ 8, + 8), # TL +0/+0
#                ((cell * 16) - Vector2(-8,-8)) + Vector2(- 8, + 8), # TR +0/+16
#                ((cell * 16) - Vector2(-8,-8)) + Vector2(- 8, - 8), # BL +0/-16
#                ((cell * 16) - Vector2(-8,-8)) + Vector2(+ 8, - 8), # BR -16/-16
#            ]
#
#            for corner in corners: 
#                c_i = Corner.instance()
#                c_i.global_position = corner
#                get_tree().root.add_child(c_i)
#
#                var length = global_position - corner
#
#                if length.length() > 15:
#                    continue
#
#                body.set_cellv(cell, 1)


func inside_circle(center: Vector2, tile: Vector2, radius: float) -> bool:
    var dx = center.x - tile.x;
    var dy = center.y - tile.y;
    var distance = sqrt(dx*dx + dy*dy);
    
    return distance <= radius;
