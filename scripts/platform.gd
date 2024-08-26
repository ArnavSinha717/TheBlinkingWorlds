extends AnimatableBody2D

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var waiting_timer: Timer = $WaitingTimer

@export var platform_waiting_time: float = 1.0
@export var speed: float = 60

var moveable: bool = true
var direction: int = 1

func _ready() -> void:
	waiting_timer.wait_time = platform_waiting_time

func _physics_process(delta: float) -> void:
	if moveable:
		position.x += direction * speed * delta
	
	if ray_cast_right.is_colliding() and moveable:
		start_waiting()
		ray_cast_right.enabled = false
		ray_cast_left.enabled = true
		direction = -1
		
	if ray_cast_left.is_colliding() and moveable:
		start_waiting()
		ray_cast_right.enabled = true
		ray_cast_left.enabled = false
		direction = 1


func start_waiting():
	waiting_timer.start()
	moveable = false if moveable == true else true


func _on_waiting_timer_timeout() -> void:
	moveable = true
