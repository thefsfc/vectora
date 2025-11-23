extends Node

@onready var pause_screen = $"../UILayer/PauseScreen"

@onready var main_node = get_parent() 

func _input(event):
	if event.is_action_pressed("pause_game"):
		var tree = get_tree()
		if main_node.game_over:
			return
		if !tree.paused:
			pause_screen.visible = true
			tree.paused = true    
		else:
			pause_screen.visible = false
			tree.paused = false

	if event.is_action_pressed("game_reload"):
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("leave_game"):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
