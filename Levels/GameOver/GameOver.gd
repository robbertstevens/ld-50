extends Level

onready var time_label = $CanvasLayer/RichTextLabel

func _ready() -> void:
    var time_string = time_label.text
    
    
    if data.has("alive_time"):
        var seconds  = data.alive_time
        
        time_label.text = time_string.format({"time": "%0.2f" % seconds})


func _on_Button_pressed() -> void:
    end_level({})
    
