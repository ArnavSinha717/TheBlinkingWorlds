extends Area2D

@onready var game_manager = get_node("/root/GameManager")

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body is the player
	if body.name == "PersistentPlayer" or body.name == "Player":
		print("Player fell off the map - Resetting...")
		# Call the restart function from GameManager
		if game_manager:
			game_manager.restart_player()
		else:
			print("GameManager not found!")
