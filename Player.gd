extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CONTROLLER_DEADZONE = 0.2

var current_shader_material: ShaderMaterial = null
@onready var animated_sprite = $AnimatedSprite2D
func _ready():
	# Print controller info for debugging
	if Input.get_connected_joypads().size() > 0:
		print("Controller connected: ", Input.get_joy_name(0))
		print("Controller GUID: ", Input.get_joy_guid(0))

	# Check current world and apply shader if in World2
	apply_world_shader()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump with keyboard Space/Enter OR controller A button (Xbox 360)
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

	# Movement using unified input system (keyboard + controller)
	var direction = 0.0

	# Try the new move actions first (includes both keyboard and controller)
	direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	# Fallback to UI actions if move actions aren't working
	if abs(direction) < 0.01:
		direction = Input.get_axis("ui_left", "ui_right")

	# Additional direct controller check as backup
	if abs(direction) < 0.01 and Input.get_connected_joypads().size() > 0:
		var controller_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X as JoyAxis)
		if abs(controller_x) > CONTROLLER_DEADZONE:
			direction = controller_x
			print("Direct controller input: ", controller_x)

	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func apply_world_shader():
	# Get the GameManager to check current world
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		return

	# Find the sprite child
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return

	# Apply or remove shader based on current world
	if game_manager.current_world == "World2":
		# Apply grayscale shader
		if not current_shader_material:
			var shader_path = "res://World2/entity_grayscale.gdshader"
			if ResourceLoader.exists(shader_path):
				current_shader_material = ShaderMaterial.new()
				current_shader_material.shader = load(shader_path)
				current_shader_material.set_shader_parameter("grayscale_amount", 0.6)
				current_shader_material.set_shader_parameter("saturation", 0.3)
				current_shader_material.set_shader_parameter("brightness", -0.02)
				current_shader_material.set_shader_parameter("contrast", 1.1)
				current_shader_material.set_shader_parameter("tint_color", Color(0.85, 0.85, 0.95, 1.0))
				current_shader_material.set_shader_parameter("tint_strength", 0.15)
		sprite.material = current_shader_material
	else:
		# Remove shader in World1
		sprite.material = null
