extends CharacterBody2D
class_name Player

enum State { NORMAL, ROLLING }

@onready var death_timer: Timer = $DeathTimer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var audioPlayer: AnimationPlayer = $AudioPlayerController
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hitbox: CollisionShape2D = $StompArea/CollisionShape2D

const ACCELERATION: float = 1300.0
const MAX_HORIZONTAL_SPEED: float = 120.0
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -200.0

var current_state = State.NORMAL
var dead: bool = false
var hit: bool = false
var rolling: bool = false
var health: int = 5
var roll_speed: float = 190.0
var last_direction: int = 1;

func _ready() -> void:
	SignalManager.player_hit.connect(Callable(self, "on_player_hit"))
	SignalManager.player_health_ui_setup.emit(health)
	SignalManager.player_bounce.connect(Callable(self, "on_bounce"))


func _physics_process(delta: float) -> void:
	match current_state:
		State.NORMAL:
			process_normal(delta)
		State.ROLLING:
			process_roll(delta)


func process_normal(delta: float):
	if velocity.y > 0:
		hitbox.disabled = false
	else:
		hitbox.disabled = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or !coyote_timer.is_stopped()) and !dead:
		velocity.y = JUMP_VELOCITY
		audioPlayer.play("jump")
		coyote_timer.stop()

	# Get the input direction and handle the movement/deceleration.
	var direction: int = get_direction()
	
	if direction and !dead:
		velocity.x += direction * ACCELERATION * delta
	else:
		#velocity.x += move_toward(velocity.x, 0, SPEED)
		velocity.x = lerp(0.0, velocity.x, pow(2, -25 * delta));
	
	velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	
	if Input.is_action_just_pressed("roll") and !dead:
		change_state(State.ROLLING)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
	
	get_animation()


func process_roll(_delta: float):
	rolling = true
	anim.play("roll")
	velocity = Vector2(roll_speed * last_direction, 0)
	
	move_and_slide()


func change_state(new_state: State):
	current_state = new_state


func get_direction() -> int:
	var dir: float = Input.get_axis("move_left", "move_right")
	var actual_direction = sign(dir)
	if (last_direction > 0 or last_direction < 0) and actual_direction == 0:
		last_direction = last_direction
	else:
		last_direction = actual_direction
	
	return actual_direction


func on_player_hit():
	if rolling == false:
		audioPlayer.play("hurt")
		SignalManager.camera_shake.emit()
		
		if health > 0 and dead != true:
			hit = true
			health -= 1
			SignalManager.player_health_changed.emit(health)
			
		elif dead != true:
			dead = true
			anim.play("death")
			death_timer.start()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		hit = false
	if anim_name == "roll":
		rolling = false
		call_deferred("change_state", State.NORMAL)


func _on_timer_timeout() -> void:
	SignalManager.player_died.emit()


func get_animation():
	var direction = get_direction()
	
	if hit == true:
		anim.play("hit")
	
	if is_on_floor() and !dead and !hit:
		if direction == 0:
			anim.play("idle")
		else:
			anim.play("run")
	elif !is_on_floor() and !dead and !hit:
		anim.play("jump")
	
	if !dead:
		if direction > 0:
			sprite.scale.x = 1
		elif direction < 0:
			sprite.scale.x = -1


func on_bounce():
	velocity.y = BOUNCE_VELOCITY
