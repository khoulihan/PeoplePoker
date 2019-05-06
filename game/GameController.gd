extends Node2D

const Player = preload("res://game/human/player/Player.gd")

signal rescued_updated (new_total)
signal player_spawned (new_player)

var _player_scene = preload("res://game/human/player/Player.tscn")
var _speech_bubble_scene = preload("res://game/ui/speech_bubble/SpeechBubble.tscn")

var _player : Player
var _goal_reached : bool = false
var _player_killed : bool = false

var _fingers : Array = []

var _rescued : int = 0

func _ready():
	randomize()
	WindowController.resize_window()
	WindowController.set_aspect_for_game()
	_populate_finger_array()
	for human in $YSort/Humans.get_children():
		human.connect("speak", self, "_human_speak", [human])
	spawn_player()
	FadeMask.connect("fade_in_complete", self, "_restart_game")

func _human_speak(speech, human):
	var bubble = _speech_bubble_scene.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
	bubble.connect("speech_timed_out", human, "on_speech_timed_out") 
	bubble.connect("speech_timed_out", self, "_speech_bubble_timed_out", [bubble])
	$SpeechBubbles.add_child(bubble)
	bubble.display_speech(speech, 4.0, human.position)

func _speech_bubble_timed_out(bubble):
	$SpeechBubbles.remove_child(bubble)
	bubble.queue_free()

func _restart_game():
	if _player_killed:
		_player_killed = false
		_rescued = 0
		emit_signal("rescued_updated", _rescued)
	_configure_level()
	spawn_player()
	FadeMask.fade_out()

func _configure_level():
	if _rescued < 2:
		enable_all($YSort/Level1Cover)
		enable_all($YSort/Level2Cover)
		enable_all($YSort/Level3Cover)
		enable_all($YSort/Level4Cover)
	elif _rescued < 4:
		disable_all($YSort/Level1Cover)
	elif _rescued < 6:
		disable_all($YSort/Level2Cover)
	elif _rescued < 8:
		disable_all($YSort/Level3Cover)

func enable_all(node):
	for n in node.get_children():
		n.enable()

func disable_all(node):
	for n in node.get_children():
		n.disable()

func _populate_finger_array():
	_fingers = $Fingers.get_children()
	for finger in _fingers:
		finger.connect("attack_complete", self, "_on_Finger_attack_complete", [finger])

func _on_Finger_attack_complete(finger):
	print("Finger attack complete")
	var next_finger = finger #= _fingers[randi() % len(_fingers)]
	#next_finger.pursue(_player)
	while next_finger == finger:
		next_finger = _fingers[randi() % len(_fingers)]
	print("Next finger pursuing")
	next_finger.pursue(_player)

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
	_player.run_speed = 140
	_player.max_stamina = 100
	_player.roll_speed = 300
	_player.run_stamina_drain = 50
	_player.stamina_recharge = 20
	$YSort.add_child(_player)
	#var camera = $YSort/Camera
	#$YSort.remove_child(camera)
	#_player.add_child(camera)
	#camera.current = true
	#camera.position = Vector2(0,0)
	_player.configure(null)
	$CameraTarget.follow(_player)
	_reset_all_fingers()
	for human in $YSort/Humans.get_children():
		human.sex = randi() % 2
		human.configure(_player)
	connect_player_signals()
	emit_signal("player_spawned", _player)

func _on_Goal_body_entered(body, which):
	if body == _player and !_goal_reached:
		_goal_reached = true
		if _player.is_alive():
			_rescued += 1
			$GoalSoundPlayer.play()
			emit_signal("rescued_updated", _rescued)
		$CameraTarget.follow(null)
		_abandon_all_pursuits()
		#var camera = _player.get_node("Camera")
		#var camera_pos = camera.get_camera_position()
		_player.disable_collider()
		disconnect_player_signals()
		$YSort.remove_child(_player)
		#_player.remove_child(camera)
		#$YSort.add_child(camera)
		#camera.position = camera_pos
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

func disconnect_player_signals():
	_player.disconnect("entered_cover", self, "_player_entered_cover")
	_player.disconnect("exited_cover", self, "_player_exited_cover")
	_player.disconnect("killed", self, "_player_killed")

func connect_player_signals():
	_player.connect("entered_cover", self, "_player_entered_cover")
	_player.connect("exited_cover", self, "_player_exited_cover")
	_player.connect("killed", self, "_player_killed")

func _player_entered_cover() -> void:
	_abandon_all_pursuits()

func _abandon_all_pursuits() -> void:
	for finger in _fingers:
		finger.abandon()

func _reset_all_fingers() -> void:
	for finger in _fingers:
		finger.reset()

func _player_exited_cover() -> void:
	# TODO: Might want to wait before activating a finger, but for now just doing it straight away
	var finger = _fingers[randi() % len(_fingers)]
	finger.pursue(_player)

func _player_killed() -> void:
	_abandon_all_pursuits()
	_player_killed = true
	$CameraTarget.follow(null)
	$RespawnTimer.start()

func _on_RespawnTimer_timeout():
	FadeMask.fade_in()
