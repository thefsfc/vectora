extends Node

func _unhandled_input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		var window = get_window()
		var current_mode = window.mode
		if current_mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
			window.size = Vector2i(1280, 720)
			window.content_scale_size = Vector2i(854, 480) 
			window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
			window.move_to_center()
		else:
			window.mode = Window.MODE_FULLSCREEN
