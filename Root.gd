extends Node2D

export (Array, PackedScene) var levels = []

var level_list := []
var current_level_instance = null

func _ready() -> void:
    reset()
    next_level({})


func next_level(data: Dictionary) -> void:
    var level = get_next_level()
    
    load_level(level, data)


func _on_current_level_instance_level_ended(data) -> void:
    next_level(data)


func get_next_level() -> PackedScene:
    var level = level_list.pop_front()
    
    if not level:
        reset()
        level = level_list.pop_front()
        
    return level


func reset() -> void:
    level_list = levels.duplicate()


func load_level(level: PackedScene, data: Dictionary) -> void:
    if current_level_instance:
        remove_child(current_level_instance)
        current_level_instance.queue_free()
    
    var current_level_scene = level
    
    current_level_instance = current_level_scene.instance()
    current_level_instance.data = data

    if utils.object_has_signal(current_level_instance, "level_ended"):
        current_level_instance.connect("level_ended", self, "_on_current_level_instance_level_ended")
    
    call_deferred("add_child", current_level_instance)
