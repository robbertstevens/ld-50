extends KinematicBody2D

signal bomb_thrown(position, target)
signal land_build(position)
signal died()


export var speed = 10

onready var state_manager = $StateManager
onready var crosshair = $Crosshair
onready var drowning_timer = $DrowningTimer

enum States {
    Idle,
    Walking,
    PrepareAttacking,
    Aiming,
    Attacking,
    PrepareBuilding,
    Building,
    Drowning,
    Died,
    Dead
}


var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
    var state_fn = {
        States.Idle: funcref(self, "_idle_state"),
        States.Walking: funcref(self, "_walking_state"),
        States.PrepareAttacking: funcref(self, "_prepare_attacking_state"),
        States.Aiming: funcref(self, "_aiming_state"),
        States.Attacking: funcref(self, "_attacking_state"),
        States.PrepareBuilding: funcref(self, "_prepare_building_state"),
        States.Building: funcref(self, "_building_state"),
        States.Drowning: funcref(self, "_drowning_state"),
        States.Died: funcref(self, "_died_state"),
        States.Dead: funcref(self, "_dead_state"),
    }
    
    state_manager.init(States, state_fn, States.Idle)
    crosshair.hide()


func _physics_process(delta: float) -> void:
    state_manager.physics_process(delta)
    
    var collisions = move_and_collide(Vector2.LEFT, true, true, true)
    
    if collisions and is_alive():
        state_manager.change_state(States.Drowning)


func _idle_state(_delta: float) -> int:
    return States.Idle


func _walking_state(_delta: float) -> int:
    direction = get_direction()
    
    if direction.length() <= 0: 
        return state_manager.change_state(States.Idle)
    
    var normalized = direction.normalized()
   
    velocity = move_and_slide(normalized * speed)
    
    return States.Walking


func _prepare_attacking_state(_delta: float) -> int:
    crosshair.show()
    crosshair.global_position = global_position
    
    return States.Aiming


func _aiming_state(delta: float) -> int:
    direction = get_direction()
    
    var aim_distance = crosshair.position + direction.normalized()
    
    if not aim_distance.length() > 69:
        crosshair.position = aim_distance
    
    return States.Aiming


func _attacking_state(delta: float) -> int:
    crosshair.hide()
    
    emit_signal("bomb_thrown", global_position, crosshair.global_position)

    return States.Idle


func _prepare_building_state(delta: float) -> int:
    var dir = get_direction()
    var aimed_at = global_position + (dir.normalized() * 8)
    
    crosshair.show()
    
    crosshair.global_position = aimed_at
    
    return States.PrepareBuilding


func _building_state(delta: float) -> int:
    crosshair.hide()
    
    emit_signal('land_build', crosshair.global_position)
    
    return States.Idle


func _drowning_state(delta: float) -> int:
    if drowning_timer.is_stopped():
        drowning_timer.start()
    
    return States.Drowning

func _died_state(delta: float) -> int:
    emit_signal('died')
    return States.Dead

func _dead_state(delta: float) -> int:
    return States.Dead


func _input(event: InputEvent) -> void:
    var direction = get_direction()

    # check if player is 'alive'
    if is_alive():
        if direction.length() > 0 and state_manager.isState(States.Idle):
            state_manager.change_state(States.Walking)

        if event.is_action_pressed("ui_build"):
            state_manager.change_state(States.PrepareBuilding)
            
        if event.is_action_released("ui_build"):
            state_manager.change_state(States.Building)

func is_alive() -> bool:
    return not (state_manager.isState(States.Drowning) or state_manager.isState(States.Dead))


func get_direction() -> Vector2:
    var direction: Vector2 = Vector2.ZERO
    
    direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    
    return direction


func _on_HitBox_body_entered(body: Node) -> void:
    return 
    if not body.name == "Water":
        return
        
    state_manager.change_state(States.Drowning)


func _on_DrowningTimer_timeout() -> void:
    state_manager.change_state(States.Died)
