extends Area2D

@export var health_point: int = 5
@onready var anim: AnimationPlayer = $AnimationPlayer

func _on_body_entered(_body: Node2D) -> void:
	SignalManager.fruit_pickup.emit(health_point)
	anim.play("pickup")
