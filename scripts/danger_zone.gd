extends Area2D
class_name DangerZone

@export var kill = false
@export var damage = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player = body as Player
		if kill:
			player.die()
		else:
			player.take_damage(damage, global_position.x)
