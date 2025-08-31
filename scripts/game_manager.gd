extends Node
class_name GameManager

@export var hud: HUD;

var score = 0

func _ready() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var creature = player.get_node("Creature")
        await hud.ready
        hud.init_hearts(creature.max_hp)
        creature.health_changed.connect(update_health)

func update_health(hp: int) -> void:
    hud.update_health_display(hp)

func add_point():
    score += 1
    hud.update_coin_display(score)
