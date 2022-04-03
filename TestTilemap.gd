extends TileMap

func _input(event: InputEvent) -> void:
    if event.is_action_pressed('ui_accept'):
            var mouse :Vector2 = get_global_mouse_position()
            var cell :Vector2 = world_to_map(mouse)
            var abc :int = get_cellv(cell)
            var new_abc :int = 1 if abc == -1 else -1
            
            set_cellv(cell, new_abc)
            update_bitmask_area(cell)


