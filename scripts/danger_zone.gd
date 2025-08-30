extends Area2D
class_name DangerZone

@export var kill = false
@export var damage = 1

var current_group
var target_group

func _ready() -> void:
    current_group = get_groups()[0]
    
    if current_group.contains("player"):
        target_group = "enemies"
    elif current_group.contains("enemies"):
        target_group = "player"

func _on_body_entered(body: Node2D) -> void:
    on_collision(body)

func _on_area_entered(area: Area2D) -> void:
    on_collision(area)

func on_collision(body: Node2D) -> void:
    if body.is_in_group(target_group):
        var creature = body.get_node("Creature") as Creature
        if kill:
            creature.kill()
        else:
            creature.take_damage(damage, global_position.x)
