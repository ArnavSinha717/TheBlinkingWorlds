extends Node

class_name BackgroundManager

static func add_background_to_world(world_scene: Node, is_world2: bool = false):
	# Check if background already exists
	if world_scene.has_node("ParallaxBackground"):
		return

	# Create ParallaxBackground node
	var parallax_bg = ParallaxBackground.new()
	parallax_bg.name = "ParallaxBackground"

	# Create ParallaxLayer
	var parallax_layer = ParallaxLayer.new()
	parallax_layer.motion_scale = Vector2(0.5, 0.5)
	parallax_layer.motion_mirroring = Vector2(1920, 0)
	parallax_bg.add_child(parallax_layer)

	# Create background sprite
	var bg_sprite = Sprite2D.new()
	bg_sprite.name = "BackgroundSprite"
	bg_sprite.centered = false
	bg_sprite.scale = Vector2(1.875, 1.875)
	
	parallax_layer.add_child(bg_sprite)

	# Try to load Treasure Hunters background
	var treasure_bg_path = "res://TreasureHunters/Backgrounds/BG Image.png"
	var test_bg_path = "res://TreasureHunters/Backgrounds/test_background.png"
	var background_texture: Texture2D = null

	if ResourceLoader.exists(treasure_bg_path):
		background_texture = load(treasure_bg_path)
		print("Loaded Treasure Hunters background for ", "World2" if is_world2 else "World1")
	elif ResourceLoader.exists(test_bg_path):
		background_texture = load(test_bg_path)
		print("Using test background for ", "World2" if is_world2 else "World1")
	else:
		# Create a simple gradient background as fallback
		print("No background found. Please place 'BG Image.png' in TreasureHunters/Backgrounds/")

	if background_texture:
		bg_sprite.texture = background_texture

		# Apply grayscale shader for World2
		if is_world2:
			var shader_path = "res://World2/grayscale.gdshader"
			if ResourceLoader.exists(shader_path):
				var shader_material = ShaderMaterial.new()
				shader_material.shader = load(shader_path)
				shader_material.set_shader_parameter("grayscale_strength", 0.85)
				shader_material.set_shader_parameter("contrast", 1.2)
				shader_material.set_shader_parameter("brightness", -0.15)
				bg_sprite.material = shader_material

				# Also apply shader to the tilemap if it exists
				apply_grayscale_to_tilemap(world_scene, shader_material)

	# Add to scene as first child (so it renders behind everything)
	world_scene.add_child(parallax_bg)
	world_scene.move_child(parallax_bg, 0)

static func apply_grayscale_to_tilemap(world_scene: Node, shader_material: ShaderMaterial):
	# Find and apply shader to TileMap nodes
	for child in world_scene.get_children():
		if child is TileMap:
			var new_material = ShaderMaterial.new()
			new_material.shader = shader_material.shader
			new_material.set_shader_parameter("grayscale_strength", 0.7)
			new_material.set_shader_parameter("contrast", 1.1)
			new_material.set_shader_parameter("brightness", -0.05)
			child.material = new_material
			print("Applied grayscale shader to TileMap: ", child.name)
