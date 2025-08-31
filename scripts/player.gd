extends CharacterBody2D
class_name Player

@export var speed = 130.0
@export var jump_velocity = -300.0
@export var roll_speed = 200.0

var facing_direction = 1
var is_knocked_back = false
var will_roll = false
var is_rolling = false

@onready var creature: Creature = $Creature
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $Sounds/JumpSound
@onready var roll_sound: AudioStreamPlayer2D = $Sounds/RollSound
@onready var knockback_timer: Timer = $Timers/KnockbackTimer
@onready var blink_timer: Timer = $Timers/BlinkTimer
@onready var attack_zone: CollisionShape2D = $DangerZone/CollisionShape2D

func _ready() -> void:
    attack_zone.disabled = true
    creature.took_damage.connect(took_damage)
    creature.knockback.connect(knockback)
    creature.died.connect(died)
    creature.death_timer_timeout.connect(game_over)

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    if creature.is_alive() and not is_knocked_back:
        # Handle jump.
        if Input.is_action_just_pressed("jump") and is_on_floor() and not will_roll and not is_rolling:
            jump()

        if Input.is_action_just_pressed("roll") and is_on_floor():
            roll()

        if is_rolling:
            velocity.x = roll_speed * facing_direction
        else:
            # Get the input direction and handle the movement/deceleration.
            # As good practice, you should replace UI actions with custom gameplay actions.
            var direction := Input.get_axis("move_left", "move_right")
            if direction:
                facing_direction = -1 if direction < 0 else 1
                velocity.x = direction * speed
            else:
                velocity.x = move_toward(velocity.x, 0, speed)

    move_and_slide()

func _process(_delta: float) -> void:
    play_animation()

func jump() -> void:
    velocity.y = jump_velocity
    jump_sound.pitch_scale = randf_range(0.8, 1.2)
    jump_sound.play()

func roll() -> void:
    will_roll = true
    animated_sprite.play("roll")


func play_animation() -> void:
    if creature.is_alive():
        # Don't change animation / Don't turn
        if animated_sprite.animation == "hurt" and animated_sprite.is_playing():
            return

        # Turn
        var direction = velocity.x
        animated_sprite.flip_h = facing_direction == -1

        # Don't change
        if will_roll or is_rolling:
            return
        
        if is_on_floor():
            if direction:
                animated_sprite.play("walk")
            else:
                animated_sprite.play("idle")
        else:
            animated_sprite.play("jump")

func took_damage(_amount: int) -> void:
    animated_sprite.play("hurt")
    creature.is_invulnerable = true

func knockback(source_x: float) -> void:
    is_knocked_back = true
    knockback_timer.start()
    blink_timer.start()
    if position.x < source_x:
        velocity.x = -100
    else:
        velocity.x = 100
    velocity.y = -150

func died() -> void:
    velocity.x = 0
    animated_sprite.play("die")
    Engine.time_scale = 0.5

func game_over() -> void:
    Engine.time_scale = 1
    get_tree().reload_current_scene()

# Animated Sprite
func _on_animated_sprite_2d_frame_changed() -> void:
    if not animated_sprite:
        return
    if animated_sprite.animation == "roll" and animated_sprite.frame == 2:
        will_roll = false
        is_rolling = true
        attack_zone.disabled = false
        creature.is_invulnerable = true
        roll_sound.pitch_scale = randf_range(0.8, 1.2)
        roll_sound.play()
    if animated_sprite.animation == "roll" and animated_sprite.frame == 6:
        is_rolling = false
        attack_zone.disabled = true
        creature.is_invulnerable = false

# Timers
func _on_knockback_timer_timeout() -> void:
    is_knocked_back = false
    animated_sprite.modulate.a = 1.0
    blink_timer.stop()
    creature.is_invulnerable = false

func _on_blink_timer_timeout() -> void:
    if animated_sprite.modulate.a == 1.0:
        animated_sprite.modulate.a = 0.3
    else:
        animated_sprite.modulate.a = 1.0
