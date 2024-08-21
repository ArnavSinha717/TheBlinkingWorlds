extends Area2D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _on_body_entered(_body: Node2D) -> void:
	SignalManager.coin_pickup.emit()
	anim.play("pickup")
