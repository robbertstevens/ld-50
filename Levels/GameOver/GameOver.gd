extends Level

onready var time_label = $CanvasLayer/RichTextLabel

func _ready() -> void:
    var time_string = time_label.text
    
    if data.has("alive_time"):
        time_label.text = time_string.replace("{time}", data.alive_time)
