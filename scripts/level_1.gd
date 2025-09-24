extends Node2D

@onready var world1_tilemap: TileMap = $World1TileMap
@onready var world2_tilemap: TileMap = $World2TileMap
@onready var player: CharacterBody2D = $Player
@onready var world_indicator: Label = $CanvasLayer/WorldIndicator

var current_world: int = 1
var switch_cooldown: float = 0.0
const SWITCH_COOLDOWN_TIME: float = 0.5

func _ready() -> void:
	# Connect to world switch signal
	SignalManager.world_switch_requested.connect(Callable(self, "on_world_switch_requested"))
	# Start with world 1 visible
	set_world(1)

func _process(delta: float) -> void:
	# Handle cooldown
	if switch_cooldown > 0:
		switch_cooldown -= delta

func on_world_switch_requested() -> void:
	if switch_cooldown <= 0:
		switch_world()

func switch_world() -> void:
	# Toggle between world 1 and world 2
	if current_world == 1:
		set_world(2)
	else:
		set_world(1)

	# Set cooldown to prevent rapid switching
	switch_cooldown = SWITCH_COOLDOWN_TIME

	# Play switch effect (visual feedback)
	play_switch_effect()

func set_world(world_num: int) -> void:
	current_world = world_num

	if world_num == 1:
		world1_tilemap.visible = true
		world1_tilemap.set_layer_enabled(0, true)
		world2_tilemap.visible = false
		world2_tilemap.set_layer_enabled(0, false)
		world_indicator.text = "World 1 - Press F to switch"
		world_indicator.modulate = Color(0.5, 0.8, 1.0)  # Blue tint
	else:
		world1_tilemap.visible = false
		world1_tilemap.set_layer_enabled(0, false)
		world2_tilemap.visible = true
		world2_tilemap.set_layer_enabled(0, true)
		world_indicator.text = "World 2 - Press F to switch"
		world_indicator.modulate = Color(1.0, 0.5, 0.5)  # Red tint

func play_switch_effect() -> void:
	# Create a visual effect for world switching
	var tween = create_tween()

	# Flash effect
	var flash_overlay = ColorRect.new()
	flash_overlay.color = Color(1, 1, 1, 0.5)
	flash_overlay.size = get_viewport().size
	$CanvasLayer.add_child(flash_overlay)

	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.3)
	tween.tween_callback(flash_overlay.queue_free)
