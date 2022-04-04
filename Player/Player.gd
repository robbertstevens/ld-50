extends KinematicBody2D

signal bomb_thrown(position, target)
signal dashed(position)
signal dirt_picked_up()
signal land_build(position)
signal alive_time_updated(new_time)
signal died()


export var speed = 10

onready var state_manager = $StateManager
onready var crosshair = $Crosshair

onready var drowning_timer = $DrowningTimer
onready var dash_timer = $DashTimer
onready var dash_cooldown_timer = $DashCooldownTimer

onready var animation_manager = $AnimatedSprite
onready var dash_sound = $DashAudioStreamPlayer
onready var drowning_sound = $DrowningAudioStreamPlayer
onready var pickup_sound = $PickupAudioStreamPlayer


enum States {
    Idle,
    Walking,
    PrepareBuilding,
    Building,
    Drowning,
    Died,
    Dead,
    Dash,
}


var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var crosshair_origin: Vector2
var time_alive := 0.0 setget set_time_alive

var rng = RandomNumberGenerator.new()


func _ready() -> void:
    var state_fn = {
        States.Idle: funcref(self, "_idle_state"),
        States.Walking: funcref(self, "_walking_state"),
        States.PrepareBuilding: funcref(self, "_prepare_building_state"),
        States.Building: funcref(self, "_building_state"),
        States.Drowning: funcref(self, "_drowning_state"),
        States.Died: funcref(self, "_died_state"),
        States.Dead: funcref(self, "_dead_state"),
        States.Dash: funcref(self, "_dash_state"),
    }
    
    state_manager.init(States, state_fn, States.Idle)
    crosshair_origin = crosshair.position
    crosshair.hide()
    
    rng.randomize()

func _process(delta: float) -> void:
    if is_alive():
        self.time_alive += delta

func _physics_process(delta: float) -> void:
    state_manager.physics_process(delta)
    
    var collisions = move_and_collide(Vector2.LEFT, true, true, true)
    
    if collisions and collisions.collider.name == "Water" and is_alive():
        state_manager.change_state(States.Drowning)


func _idle_state(_delta: float) -> int:
    animation_manager.play("idle")
    return States.Idle


func _walking_state(_delta: float) -> int:
    direction = get_direction()
    
    animation_manager.play("walking")
    if direction.x > 0: animation_manager.flip_h = false
    if direction.x < 0: animation_manager.flip_h = true
    
    if direction.length() <= 0: 
        return state_manager.change_state(States.Idle)
    
    var normalized = direction.normalized()
   
    velocity = move_and_slide(normalized * speed)
    
    return States.Walking


func _dash_state(delta: float) -> int:    
    if dash_timer.is_stopped():
        dash_timer.start()
        dash_cooldown_timer.start()
        
        direction = get_direction()
        
        dash_sound.pitch_scale = rng.randf_range(0.85, 1.15)
        dash_sound.play()
    
    animation_manager.play("dash")
    
    emit_signal("dashed", global_position)
        
    $CollisionShape2D.disabled = true
        
    var normalized = direction.normalized()
   
    velocity = move_and_slide(normalized * 500)
    
    return States.Dash


func _prepare_building_state(delta: float) -> int:
    var dir = get_direction()
    
    var aimed_at = crosshair_origin + (dir.normalized() * 8)
    
    animation_manager.play("idle")    
    
    crosshair.show()
    
    crosshair.position = aimed_at
    
    return States.PrepareBuilding


func _building_state(delta: float) -> int:
    crosshair.hide()
    
    emit_signal('land_build', crosshair.global_position)
    
    return States.Idle


func _drowning_state(delta: float) -> int:
    if drowning_timer.is_stopped():
        drowning_timer.start()
        
        drowning_sound.play()
        
    
    animation_manager.play("drowning")
    
    return States.Drowning

func _died_state(delta: float) -> int:
    emit_signal('died')
    animation_manager.play("dead")
    return States.Dead

func _dead_state(delta: float) -> int:
    return States.Dead


func _input(event: InputEvent) -> void:
    var direction = get_direction()

    # check if player is 'alive'
    if is_alive():
        if direction.length() > 0 and state_manager.isState(States.Idle) and can_move():
            state_manager.change_state(States.Walking)

        if event.is_action_pressed('ui_dash') and can_dash():
            state_manager.change_state(States.Dash)

        if event.is_action_pressed("ui_build"):
            state_manager.change_state(States.PrepareBuilding)
            
        if event.is_action_released("ui_build"):
            state_manager.change_state(States.Building)


func is_alive() -> bool:
    return not state_manager.isState(States.Drowning) and not state_manager.isState(States.Dead)


func can_move() -> bool:
    return not (state_manager.isState(States.Dash)) or not is_alive()

func can_dash() -> bool:
    return dash_cooldown_timer.is_stopped()

func get_direction() -> Vector2:
    var direction: Vector2 = Vector2.ZERO
    
    direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

        
    return direction


func _on_DrowningTimer_timeout() -> void:
    state_manager.change_state(States.Died)


func _on_DashTimer_timeout() -> void:
    $CollisionShape2D.disabled = false
    state_manager.change_state(state_manager.previous_state)


func _on_HitBox_area_entered(area: Area2D) -> void:
    emit_signal("dirt_picked_up")
    
    pickup_sound.play()
    
    area.get_parent().queue_free()


func set_time_alive(new_value):
    time_alive = new_value
    emit_signal('alive_time_updated', time_alive)
