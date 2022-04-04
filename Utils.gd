extends Node

static func get_enum_value(dict: Dictionary, value: int) -> String:
    return dict.keys()[value];


static func object_has_signal(object: Object, signal_name: String) -> bool:
    var list = object.get_signal_list()
    
    for signal_entry in list:
        if signal_entry["name"] == signal_name:
            return true
        
    return false


static func rotate_around_point(pos: Vector2, center: Vector2, angle: float) -> Vector2: 
    var r = angle * (PI / 180)
    
    var x = cos(r) * (pos.x - center.x) - sin(r) * (pos.y-center.y) + center.x 
    var y = sin(r) * (pos.x - center.x) + cos(r) * (pos.y-center.y) + center.y
    
    return Vector2(x, y)
