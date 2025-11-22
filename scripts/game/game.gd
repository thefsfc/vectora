extends Node2D

@onready var player_character = $Player/CharacterBody2D
@onready var hp_bar = $UILayer/HPBar
@onready var HealSpawnTimer = $HealSpawnTimer
@onready var EnemyTimer = $EnemyTimer
@onready var game_over_screen = $UILayer/GameOverScreen 

@export var enemy_scene: PackedScene 
@export var heal_scene: PackedScene

@export var base_heal_time: float = 5.0
@export var start_max_heals: int = 10 

var game_time: float = 0.0
var current_heals = 0
var base_enemy_spawn_time = 2.0 

func _ready():
	game_over_screen.visible = false
	hp_bar.max_value = player_character.max_hp
	player_character.health_updated.connect(_on_player_health_updated)
	hp_bar.value = player_character.current_hp
	EnemyTimer.wait_time = base_enemy_spawn_time
	HealSpawnTimer.wait_time = base_heal_time
func _on_player_health_updated(new_health_value):
	hp_bar.value = new_health_value
	if new_health_value <= 0:
		player_character.queue_free()
		call_deferred("show_game_over")
func show_game_over():
	game_over_screen.visible = true
	get_tree().paused = true    

func _process(delta):
	game_time += delta

func _on_enemy_timer_timeout() -> void:
	if enemy_scene == null:
		return
	var enemy_spawn_difficulty = 1.0 + (game_time / 120.0)
	var enemy = enemy_scene.instantiate()
	var viewport_size = get_viewport_rect().size
	var spawn_side = randi() % 4
	var spawn_pos = get_pos_by_side(spawn_side, viewport_size)
	var target_side = -1
	match spawn_side:
		0: target_side = 1
		1: target_side = 0
		2: target_side = 3
		3: target_side = 2
	var target_pos = get_pos_by_side(target_side, viewport_size)
	enemy.position = spawn_pos
	enemy.direction = (target_pos - spawn_pos).normalized()
	add_child(enemy)
	var new_time = base_enemy_spawn_time / enemy_spawn_difficulty
	EnemyTimer.wait_time = max(0.3, new_time)

func get_pos_by_side(side: int, viewport_size: Vector2) -> Vector2:
	var offset = 50
	var pos = Vector2.ZERO
	match side:
		0:
			pos.x = randf_range(0, viewport_size.x)
			pos.y = -offset
		1:
			pos.x = randf_range(0, viewport_size.x)
			pos.y = viewport_size.y + offset
		2:
			pos.x = -offset
			pos.y = randf_range(0, viewport_size.y)
		3:
			pos.x = viewport_size.x + offset
			pos.y = randf_range(0, viewport_size.y)
	return pos

func _on_heal_spawn_timer_timeout() -> void:
	if heal_scene == null:
		return
	var hp_item_spawn_difficulty = 1.0 + (game_time / 120.0)
	var dynamic_limit = max(2, int(start_max_heals / hp_item_spawn_difficulty))
	if current_heals >= dynamic_limit:
		return 
	var heal = heal_scene.instantiate()
	var margin = 30.0 
	var viewport_size = get_viewport_rect().size
	var random_x = randf_range(margin, viewport_size.x - margin)
	var random_y = randf_range(margin, viewport_size.y - margin)
	heal.position = Vector2(random_x, random_y)
	heal.freed.connect(_on_heal_freed_signal)
	add_child(heal)
	current_heals += 1
	var new_wait_time = base_heal_time * hp_item_spawn_difficulty
	HealSpawnTimer.wait_time = min(20.0, new_wait_time)

func _on_heal_freed_signal() -> void:
	current_heals -= 1
