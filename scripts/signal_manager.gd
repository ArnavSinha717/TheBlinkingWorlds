extends Node

signal player_hit # When the player gets hit
signal player_health_changed # For updating players health count UI
signal player_health_ui_setup # For setting up the Health UI for the firt time
signal fruit_pickup # For health pickup
signal coin_pickup # For updating score/coin counter
signal change_game_state # For pause and resuming game
signal player_died # For popping up the death screen
signal camera_shake # For shaking the camera
signal player_bounce # For bouncing the player when it stomps on the enemy
