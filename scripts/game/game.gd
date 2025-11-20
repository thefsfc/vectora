extends Node2D

@onready var player_character = $Player/CharacterBody2D
@onready var hp_bar = $HPBar
@export var enemy_scene: PackedScene 

func _ready():
	hp_bar.max_value = player_character.max_hp
	player_character.health_updated.connect(_on_player_health_updated)
	hp_bar.value = player_character.current_hp

func _on_player_health_updated(new_health_value):
	hp_bar.value = new_health_value
	if new_health_value <= 0:
		get_tree().reload_current_scene()

func _process(_delta):
	if Input.is_action_just_pressed("game_reload"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("leave_game"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_enemy_timer_timeout() -> void:
	if enemy_scene == null:
		return
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
