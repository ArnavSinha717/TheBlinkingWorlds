extends ParallaxBackground

@export var background_texture: Texture2D
@export var apply_grayscale: bool = false
@export var grayscale_shader: Shader

func _ready():
	# Try to load the Treasure Hunters background
	var treasure_bg_path = "res://TreasureHunters/Backgrounds/BG Image.png"

	if ResourceLoader.exists(treasure_bg_path):
		background_texture = load(treasure_bg_path)
	else:
		# Fallback to a colored background if asset not available
		print("Treasure Hunters background not found at: ", treasure_bg_path)
		print("Please place 'BG Image.png' in TreasureHunters/Backgrounds/ folder")

	# Set up the background sprite
	var sprite = $ParallaxLayer/BackgroundSprite
	if sprite and background_texture:
		sprite.texture = background_texture

		# Apply grayscale shader if needed (for World2)
		if apply_grayscale:
			var shader_material = ShaderMaterial.new()
			if grayscale_shader:
				shader_material.shader = grayscale_shader
			else:
				# Try to load the grayscale shader
				var shader_path = "res://World2/grayscale.gdshader"
				if ResourceLoader.exists(shader_path):
					shader_material.shader = load(shader_path)

			if shader_material.shader:
				shader_material.set_shader_parameter("grayscale_strength", 0.8)
				shader_material.set_shader_parameter("contrast", 1.1)
				shader_material.set_shader_parameter("brightness", -0.1)
				sprite.material = shader_material