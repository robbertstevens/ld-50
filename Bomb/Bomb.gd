extends KinematicBody2D

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
    return States.Exploding
