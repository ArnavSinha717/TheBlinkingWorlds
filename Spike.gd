extends Area2D

func _ready():
	# Connect the body_entered signal to handle collisions
	body_entered.connect(_on_body_entered)

	# Set collision layer and mask if needed
	# Make sure the spike Area2D can detect the player

func _on_body_entered(body):
	# Check if the body is the player
	if body.name == "PersistentPlayer" or body.name == "Player" or body.has_method("apply_world_shader"):
		# Get the GameManager and trigger restart
		var game_manager = get_node_or_null("/root/GameManager")
		if game_manager and game_manager.has_method("restart_player"):
			print("Player hit spikes! Respawning...")
			game_manager.restart_player()
