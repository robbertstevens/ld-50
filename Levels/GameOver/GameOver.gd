extends Level

onready var time_label = $CanvasLayer/HBoxContainer/VBoxContainer/GameOverLabel

func _ready() -> void:
    var time_string = time_label.text
    
    if data.has("alive_time"):
        var seconds  = data.alive_time
        
        time_label.text = time_string.format({"time": "%0.2f" % seconds})

func _physics_process(delta: float) -> void:
    var center = $TileMap.get_used_rect().get_center()
    
    $Zeus.global_position = utils.rotate_around_point($Zeus.global_position, center * 8, 25 * delta)


func _on_Button_pressed() -> void:
    end_level({})
    
