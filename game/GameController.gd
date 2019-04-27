extends Node2D

const Player = preload("res://game/human/player/Player.gd")

var _player_scene = preload("res://game/human/player/Player.tscn")

var _player : Player
var _goal_reached : bool = false

var _rescued : int = 0

func _ready():
	randomize()
	WindowController.resize_window()
	WindowController.set_aspect_for_game()
	spawn_player()

func spawn_player():
	if _player:
		_player.get_parent().remove_child(_player)
		_player = null
	_goal_reached = false
	var spawn_point : Position2D = $SpawnPoints.get_child(randi() % $SpawnPoints.get_child_count())
	_player = _player_scene.instance()
	_player.position = spawn_point.position
	_player.sex = randi() % 2
	# TODO: Maybe vary these with difficulty/progress
	_player.walk_speed = 100
	_player.run_speed = 200
	_player.max_stamina = 100
	_player.roll_speed = 300
	_player.run_stamina_drain = 50
	_player.stamina_recharge = 10
	$YSort.add_child(_player)
	var camera = $YSort/Camera
	$YSort.remove_child(camera)
	_player.add_child(camera)
	camera.current = true
	camera.position = Vector2(0,0)
	_player.configure()

func _on_Goal_body_entered(body, which):
	if body == _player and !_goal_reached:
		_goal_reached = true
		if _player.is_alive():
			_rescued += 1
		var camera = _player.get_node("Camera")
		var camera_pos = camera.get_camera_position()
		_player.disable_collider()
		$YSort.remove_child(_player)
		_player.remove_child(camera)
		$YSort.add_child(camera)
		camera.position = camera_pos
		var fall_motion : Vector2 = Vector2(0, 15.0)
		print(which)
		if which == "top":
			self.add_child_below_node($Background, _player)
		elif which == "bottom":
			self.add_child_below_node($YSort, _player)
		elif which == "left":
			self.add_child_below_node($YSort, _player)
			fall_motion.x = -30
		elif which == "right":
			self.add_child_below_node($YSort, _player)
			fall_motion.x = 30
		_player.enter_fall_state(fall_motion)
		$RespawnTimer.start()


func _on_RespawnTimer_timeout():
	spawn_player()
