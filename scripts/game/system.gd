extends Node

func _input(event):
	if event.is_action_pressed("pause_game"):
		var tree = get_tree()
		tree.paused = not tree.paused
		
	if event.is_action_pressed("game_reload"):
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("leave_game"):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
