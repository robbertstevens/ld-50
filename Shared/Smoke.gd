extends AnimatedSprite


func _ready() -> void:
    playing = true

func _on_Smoke_animation_finished() -> void:
    queue_free()
