extends Node

@onready var heart_empty_ui: TextureRect = %HeartEmpty
@onready var heart_full_ui: TextureRect = %HeartFull
@onready var pause_menu: CanvasLayer = %PauseMenu
@onready var death_screen: CanvasLayer = %DeathScreen
@onready var coin_count_ui: Label = %CoinCount

const UI_SIZE: int = 11
const MAX_PLAYER_HP = 5

var player_hp: int = 0
var coins: int = 0
var game_paused: bool = false
var game_pausable: bool = true

func _ready() -> void:
	game_pausable = true
	get_tree().paused = false
	update_coin_ui()
	SignalManager.player_health_changed.connect(Callable(self, "on_player_health_change"))
	SignalManager.player_health_ui_setup.connect(Callable(self, "on_player_health_ui_setup"))
	SignalManager.fruit_pickup.connect(Callable(self, "on_fruit_pickup"))
	SignalManager.change_game_state.connect(Callable(self, "on_game_state_change"))
	SignalManager.player_died.connect(Callable(self, "on_player_died"))
	SignalManager.coin_pickup.connect(Callable(self, "on_coin_pickup"))


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		SignalManager.change_game_state.emit()


func on_player_health_change(hp: int):
	player_hp = hp
	
	if hp == 0:
		hide_full_health()
	else:
		update_ui()


func on_player_health_ui_setup(hp: int):
	player_hp = hp
	heart_empty_ui.size.x = hp * UI_SIZE
	heart_full_ui.size.x = hp * UI_SIZE


func on_fruit_pickup(hp: int):
	add_hp(hp)


func update_ui():
	heart_full_ui.size.x = player_hp * UI_SIZE


func hide_full_health():
	heart_full_ui.visible = false


func add_hp(amount: int):
	player_hp += amount
	if player_hp > MAX_PLAYER_HP:
		player_hp = MAX_PLAYER_HP
	
	update_ui()


func on_game_state_change():
	if game_pausable:
		if game_paused:
			resume_game()
		else:
			pause_game()


func pause_game():
	call_engine_pause(true)
	pause_menu.visible = true
	game_paused = true

func resume_game():
	call_engine_pause(false)
	pause_menu.visible = false
	game_paused = false


func _on_resume_pressed() -> void:
	resume_game()


func _on_main_menu_pressed() -> void:
	resume_game()
	get_tree().change_scene_to_file("res://scenes/common_scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func on_player_died():
	game_pausable = false
	call_engine_pause(true)
	death_screen.visible = true


func _on_restart_pressed() -> void:
	call_engine_pause(false)
	get_tree().reload_current_scene()


func call_engine_pause(val: bool):
	get_tree().paused = val


func on_coin_pickup():
	coins += 1
	update_coin_ui()


func update_coin_ui():
	coin_count_ui.text = str(coins)
