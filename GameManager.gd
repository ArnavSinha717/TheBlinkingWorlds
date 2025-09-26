extends Node

var current_world = null
var player_instance = null
var player_scene = preload("res://Player.tscn")
var initial_spawn_position = Vector2(375, 570)  # Store initial spawn position
var is_resetting = false  # Prevent multiple resets
var last_checkpoint = {"world": null, "position": null}  # Store single global checkpoint with world info

# UDP listening for blink detection
var udp := PacketPeerUDP.new()
var listening_port = 9999
var blink_count = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Create the persistent player instance
	player_instance = player_scene.instantiate()
	player_instance.name = "PersistentPlayer"

	# Start with World1
	call_deferred("load_initial_world", "World1")

	# Setup UDP listening for blink detection
	var result = udp.bind(listening_port, "127.0.0.1")
	if result == OK:
		print("UDP listening on port " + str(listening_port) + " for blink detection")
	else:
		print("Failed to bind UDP port " + str(listening_port))

func _process(_delta):
	# Check if player has fallen too far (kill zone)
	if player_instance and player_instance.is_inside_tree() and not is_resetting:
		if player_instance.global_position.y > 1000:  # Adjust this value based on your map
			print("Player fell off the map!")
			restart_player()

	# Check for incoming UDP packets
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = packet.get_string_from_utf8()

		if message == "blink":
			blink_count += 1
			print("Blink #" + str(blink_count) + " received - Switching world")

			# Switch worlds on blink
			if current_world == "World1":
				switch_to_world("World2")
			else:
				switch_to_world("World1")

func _input(event):
	# Keep Tab key functionality as backup/testing
	if event.is_action_pressed("switch_world"):
		if current_world == "World1":
			switch_to_world("World2")
		else:
			switch_to_world("World1")

	# Restart functionality - X button on Xbox controller or R key
	if event.is_action_pressed("restart"):
		restart_player()

	# Create checkpoint - Y button on controller or Y key
	if event.is_action_pressed("create_checkpoint"):
		create_checkpoint()

	# Full reset - Right trigger or U key
	if event.is_action_pressed("full_reset"):
		full_reset()

func load_initial_world(world_name: String):
	current_world = world_name
	var world_path = get_world_scene_path(world_name)
	get_tree().change_scene_to_file(world_path)

	await get_tree().scene_changed

	var world_node = get_tree().current_scene
	if world_node:
		# Add background to the world
		BackgroundManager.add_background_to_world(world_node, world_name == "World2")

		# Remove any existing player in the scene
		var existing_player = world_node.get_node_or_null("Player")
		if existing_player:
			existing_player.queue_free()
			await existing_player.tree_exited

		existing_player = world_node.get_node_or_null("player")
		if existing_player:
			existing_player.queue_free()
			await existing_player.tree_exited

		# Add our persistent player
		world_node.call_deferred("add_child", player_instance)
		# Set initial position to a safe starting point
		player_instance.position = initial_spawn_position

func switch_to_world(world_name: String):
	if not player_instance:
		return

	# Save current player state
	var saved_position = player_instance.global_position
	var saved_velocity = player_instance.velocity

	# Remove player from current world
	if player_instance.get_parent():
		player_instance.get_parent().remove_child(player_instance)

	# Switch to new world
	current_world = world_name
	var world_path = get_world_scene_path(world_name)
	get_tree().change_scene_to_file(world_path)

	await get_tree().scene_changed

	var world_node = get_tree().current_scene
	if world_node:
		# Add background to the world
		BackgroundManager.add_background_to_world(world_node, world_name == "World2")
		# Remove any existing player in the new scene
		var existing_player = world_node.get_node_or_null("Player")
		if existing_player:
			existing_player.queue_free()
			await existing_player.tree_exited

		existing_player = world_node.get_node_or_null("player")
		if existing_player:
			existing_player.queue_free()
			await existing_player.tree_exited

		# Add our persistent player back
		world_node.add_child(player_instance)

		# Restore player state
		player_instance.global_position = saved_position
		player_instance.velocity = saved_velocity

		# Update player shader for new world
		if player_instance.has_method("apply_world_shader"):
			player_instance.apply_world_shader()

		# Wait for physics to update
		await get_tree().physics_frame
		await get_tree().physics_frame  # Wait two physics frames for proper collision detection

		# Make sure world_node is still valid
		if not world_node or not is_instance_valid(world_node):
			print("World node is invalid after scene change")
			return

		# Simple collision check using test_move
		var stuck_in_tile = false
		if player_instance and is_instance_valid(player_instance):
			stuck_in_tile = player_instance.test_move(player_instance.transform, Vector2.ZERO)

		if stuck_in_tile:
			print("Player stuck in tile, adjusting position...")

			# Try moving up to find free space
			var found_free_space = false
			var test_positions = [
				Vector2(0, -8),    # Small step up
				Vector2(0, -16),   # One tile up
				Vector2(0, -32),   # Two tiles up
				Vector2(0, -48),   # Three tiles up
				Vector2(0, -64),   # Four tiles up
				Vector2(0, -80),   # Five tiles up
				Vector2(16, -32),  # Slightly right and up
				Vector2(-16, -32), # Slightly left and up
			]

			for offset in test_positions:
				player_instance.global_position = saved_position + offset
				await get_tree().physics_frame

				# Check if this position is free
				if not player_instance.test_move(player_instance.transform, Vector2.ZERO):
					found_free_space = true
					print("Found free space at offset: ", offset)
					break

			# If no free space found nearby, move significantly up
			if not found_free_space:
				player_instance.global_position = Vector2(saved_position.x, saved_position.y - 100)
				print("No free space found nearby, moving player up by 100 pixels")

			# Reset Y velocity to let gravity take over for natural falling
			player_instance.velocity.y = 0

		print("Switched to " + world_name + " - Player at position: " + str(player_instance.global_position))

func get_world_scene_path(world_name: String) -> String:
	if world_name == "World2":
		return "res://World2/Scenes/blackworld.tscn"
	else:
		return "res://World1/Scenes/game.tscn"

func restart_player():
	if not player_instance or is_resetting:
		return

	is_resetting = true

	# Check if we have a global checkpoint
	var spawn_position = initial_spawn_position
	var spawn_world = "World1"

	if last_checkpoint["world"] != null and last_checkpoint["position"] != null:
		spawn_position = last_checkpoint["position"]
		spawn_world = last_checkpoint["world"]
		print("Respawning at last checkpoint in " + spawn_world + ": " + str(spawn_position))
	else:
		print("No checkpoint found, respawning at initial position")

	# Switch to spawn world if needed
	if current_world != spawn_world:
		await switch_to_world(spawn_world)

	# Reset player position and velocity
	player_instance.global_position = spawn_position
	player_instance.velocity = Vector2.ZERO

	# Reset the flag after a short delay
	await get_tree().create_timer(0.5).timeout
	is_resetting = false

func create_checkpoint():
	if not player_instance or not player_instance.is_inside_tree():
		print("Cannot create checkpoint: player not ready")
		return

	# Check if player is on a safe tile (on floor)
	if not player_instance.is_on_floor():
		print("Cannot create checkpoint: player must be on solid ground")
		return

	# Store global checkpoint with current world and position
	last_checkpoint["world"] = current_world
	last_checkpoint["position"] = player_instance.global_position
	print("Checkpoint created in " + current_world + " at position: " + str(player_instance.global_position))

	# Create visual feedback
	show_checkpoint_marker(player_instance.global_position)

func full_reset():
	print("Performing full reset...")

	# Clear the global checkpoint
	last_checkpoint = {"world": null, "position": null}

	# Reset to initial spawn in World1
	is_resetting = true

	if current_world != "World1":
		await switch_to_world("World1")

	player_instance.global_position = initial_spawn_position
	player_instance.velocity = Vector2.ZERO

	print("Full reset complete - checkpoint cleared")

	await get_tree().create_timer(0.5).timeout
	is_resetting = false

func show_checkpoint_marker(position: Vector2):
	# For now, just print feedback - visual marker can be added later
	print("[CHECKPOINT CREATED] - Press X/R to respawn here")

func _exit_tree():
	# Clean up UDP connection
	if udp.is_bound():
		udp.close()
