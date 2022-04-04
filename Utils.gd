extends Node

static func get_enum_value(dict: Dictionary, value: int) -> String:
    return dict.keys()[value];


static func object_has_signal(object: Object, signal_name: String) -> bool:
    var list = object.get_signal_list()
    
    for signal_entry in list:
        if signal_entry["name"] == signal_name:
            return true
        
    return false
