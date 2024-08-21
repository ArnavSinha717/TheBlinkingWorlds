extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_right: RayCast2D = $RayCastRight
@onready var ray_left: RayCast2D = $RayCastLeft

@export var speed: int = 60;
var direction: int = 1;

func _process(delta: float) -> void:
	if ray_right.is_colliding():
		direction = -1
		sprite.flip_h = true
	if ray_left.is_colliding():
		direction = 1
		sprite.flip_h = false
	
	position.x += direction * speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalManager.player_hit.emit()
