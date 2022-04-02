extends TileMap

func _input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_accept'):
            var mouse :Vector2 = get_global_mouse_position()
            var cell :Vector2 = world_to_map(mouse)
            var abc :int = get_cellv(cell)
            var new_abc :int = (abc + 1) % 2 # just an example plus 1 modules 3
            set_cellv(cell, new_abc)

