extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_right: RayCast2D = $RayCastRight
@onready var ray_left: RayCast2D = $RayCastLeft
@onready var death_timer: Timer = $DeathTimer
@onready var audio: AudioStreamPlayer2D = $Audio
@onready var damage_zone: CollisionShape2D = $DamageZone/CollisionShape2D
@onready var hitbox_area: CollisionShape2D = $HitBox/CollisionShape2D

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


func _on_hit_box_area_entered(area: Area2D) -> void:
	SignalManager.player_bounce.emit()
	call_deferred("death")
	audio.play()
	death_timer.start()


func _on_death_timer_timeout() -> void:
	queue_free()


func death():
	direction = 0
	sprite.visible = false
	damage_zone.disabled = true
	hitbox_area.disabled = true
