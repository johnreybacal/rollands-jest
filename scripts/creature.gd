extends Node2D
class_name Creature

@export var max_hp = 1
@export var death_timer_duration = 3.0
@export var hurt_sound_stream: AudioStream

signal died()
signal death_timer_timeout()
signal health_changed(hp: int)
signal took_damage(amount: int)
signal knockback(source_x: int)

var hp = 0
var is_invulnerable = false

@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var death_timer: Timer = $DeathTimer

func _ready() -> void:
    hp = max_hp
    death_timer.wait_time = death_timer_duration
    hurt_sound.stream = hurt_sound_stream

func is_alive() -> bool:
    return hp > 0

func take_damage(amount: int, source_x: float) -> void:
    if is_alive() and not is_invulnerable:
        hurt_sound.pitch_scale = randf_range(0.75, 1.25)
        hurt_sound.play()
        emit_signal("took_damage", amount)
        hp -= amount
        emit_signal("health_changed", hp)
        emit_signal("knockback", source_x)

        if hp <= 0:
            emit_signal("died")
            death_timer.start()

func kill() -> void:
    if is_alive():
        hp = 0
        emit_signal("health_changed", hp)
        emit_signal("died")
        death_timer.start()

func _on_death_timer_timeout() -> void:
    emit_signal("death_timer_timeout")
