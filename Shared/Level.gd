class_name Level

extends Node2D

signal level_ended(data)

var data: Dictionary

func end_level(data: Dictionary) -> void:
    emit_signal('level_ended', data)
