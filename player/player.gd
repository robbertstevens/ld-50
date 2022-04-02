extends KinematicBody2D

export var speed = 10

onready var state_manager = $state_manager

enum States {
    Idle,
    Walking
}

var states: Dictionary = {
    States.Idle: funcref(self, "_idle_state"),
    States.Walking: funcref(self, "_walking_state")
}

var velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
    state_manager.init(States, states, States.Idle)


func _physics_process(delta: float) -> void:
    state_manager.physics_process(delta)


func _idle_state(_delta: float) -> int:
    return States.Idle

func _walking_state(delta: float) -> int:
    var direction = get_direction()
    
    if direction.length() <= 0: 
        return state_manager.change_state(States.Idle)
    
    velocity = move_and_slide(direction.normalized() * speed)
    
    return States.Walking


func _input(event: InputEvent) -> void:
    var direction = get_direction()
    
    if direction.length() > 0: 
        state_manager.change_state(States.Walking)
    

func get_direction() -> Vector2:
    var direction: Vector2 = Vector2.ZERO
    
    direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    
    return direction
