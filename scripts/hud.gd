extends CanvasLayer
class_name HUD

@export var heart_scene: PackedScene

@onready var hearts_container: Control = $HeartsContainer
@onready var coin_label: Label = $CoinLabel

var hearts: Array[Heart] = []

func init_hearts(max_hp) -> void:
    for heart in hearts:
        heart.queue_free()
    hearts.clear()

    for i in range(max_hp):
        var heart = heart_scene.instantiate() as Heart
        heart.position = Vector2(25 + i * 20, 25)
        hearts_container.add_child(heart)
        hearts.append(heart)

func update_health_display(hp: int) -> void:
    for i in range(hearts.size()):
        hearts[i].set_filled(i < hp)

func update_coin_display(coins: int) -> void:
    coin_label.text = str(coins)