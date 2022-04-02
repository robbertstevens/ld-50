extends Node2D


var states: Dictionary
var state_fns: Dictionary

var current_state: int
var previous_state: int

func init(entity_states: Dictionary, available_state_fns: Dictionary, starting_state: int) -> void:
    state_fns = available_state_fns
    states = entity_states
    change_state(starting_state)

func change_state(new_state: int) -> int:
    if not current_state == new_state:
        previous_state = current_state
        current_state = new_state
        
#        print_debug("Changed to state: ", utils.get_enum_value(states, new_state))
    
    return current_state

func physics_process(delta: float) -> void:
    var process_func = get_state_fn(current_state)
    
    if not process_func:
        return
        
    var new_state = process_func.call_func(delta)

    if not new_state == current_state:
        change_state(new_state)


func get_state_fn(state: int) -> FuncRef:
    if state_fns.has(state): 
        assert(state_fns[state].is_valid(), "ERROR: Something is wrong with the FuncRef")
        
        return state_fns[state]
        
    return null


func isState(state: int) -> bool:
    return current_state == state
