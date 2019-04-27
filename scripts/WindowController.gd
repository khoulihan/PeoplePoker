extends Node

func resize_window():
	# TODO: If a fullscreen setting is added, this needs to have a branch that just sets fullscreen and does not specify window size
	OS.window_maximized = false
	OS.window_fullscreen = false
	OS.window_borderless = false
	OS.window_resizable = true
	OS.set_window_size(Vector2(1280, 720))
	OS.center_window()

func set_aspect_for_game():
	self.get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(320, 180))