extends Node2D
class_name Slime

const SPEED = 60

var direction = 1
var is_moving = true

@onready var creature: Creature = $Creature
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    creature.connect("took_damage", Callable(self, "took_damage"))
    creature.connect("died", Callable(self, "died"))
    creature.connect("death_timer_timeout", Callable(self, "_on_death_timer_timeout"))

func _process(delta: float) -> void:
    if ray_cast_right.is_colliding():
        direction = -1
        animated_sprite.flip_h = true
    if ray_cast_left.is_colliding():
        direction = 1
        animated_sprite.flip_h = false
    
    if is_moving and creature.is_alive():
        position.x += direction * SPEED * delta

func took_damage(_amount: int) -> void:
    animated_sprite.play("hurt")
    is_moving = false

func died() -> void:
    animated_sprite.play("die")

func _on_death_timer_timeout() -> void:
    queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
    if animated_sprite.animation == "hurt":
        animated_sprite.play("idle")
        is_moving = true
