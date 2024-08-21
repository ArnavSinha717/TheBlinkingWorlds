extends Area2D

@export var level: PackedScene;

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_packed(level)
