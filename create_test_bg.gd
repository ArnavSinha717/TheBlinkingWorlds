@tool
extends EditorScript

func _run():
	# Create a simple gradient background for testing
	var img = Image.create(1920, 1080, false, Image.FORMAT_RGBA8)

	# Create a sky gradient
	for y in range(1080):
		for x in range(1920):
			var t = float(y) / 1080.0

			# Sky gradient from light blue to darker blue
			var r = lerp(135, 25, t) / 255.0
			var g = lerp(206, 50, t) / 255.0
			var b = lerp(235, 100, t) / 255.0

			# Add some clouds
			if y > 200 and y < 400:
				var cloud_noise = sin(x * 0.01) * 0.1 + sin(x * 0.005) * 0.05
				if cloud_noise > 0.05:
					r = min(r + 0.2, 1.0)
					g = min(g + 0.2, 1.0)
					b = min(b + 0.2, 1.0)

			img.set_pixel(x, y, Color(r, g, b, 1.0))

	# Save the image
	img.save_png("res://TreasureHunters/Backgrounds/test_background.png")
	print("Test background created at res://TreasureHunters/Backgrounds/test_background.png")