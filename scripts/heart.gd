extends Node2D
class_name Heart

var is_filled = true

@onready var sprite: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:
    pass

func set_filled(filled: bool) -> void:
    is_filled = filled
    sprite.frame = 0 if is_filled else 1