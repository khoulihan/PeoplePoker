extends Node2D

const Player = preload("res://game/human/player/Player.gd")


const DEBUG = true

signal rescued_updated (new_total)
signal player_spawned (new_player)

var _player_scene = preload("res://game/human/player/Player.tscn")
var _corpse_scene = preload("res://game/human/corpse/Corpse.tscn")
var _speech_bubble_scene = preload("res://game/ui/speech_bubble/SpeechBubble.tscn")
var _drop_effect_scene = preload("res://game/drop_zone/DropEffect.tscn")
var _cover_object_scene = preload("res://game/cover/CardsCoverObject.tscn")

var _player : Player
var _goal_reached : bool = false
var _player_killed : bool = false
var _current_drop_effect = null

var _fingers : Array = []

var _rescued : int = 0

func _ready():
	randomize()
	WindowController.resize_window()
	WindowController.set_aspect_for_game()
	_configure_level()
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
	adjust_finger_difficulty()
	if _rescued < 2:
		enable_all($YSort/Level1Cover)
		enable_all($YSort/Level1Obstacles)
		disable_all($YSort/Level2Cover)
		disable_all($YSort/Level2Obstacles)
		disable_all($YSort/Level3Cover)
		disable_all($YSort/Level3Obstacles)
		disable_all($YSort/Level4Cover)
	elif _rescued < 4:
		disable_all($YSort/Level1Cover)
		disable_all($YSort/Level1Obstacles)
		enable_all($YSort/Level2Cover)
		enable_all($YSort/Level2Obstacles)
		disable_all($YSort/Level3Cover)
		disable_all($YSort/Level3Obstacles)
		disable_all($YSort/Level4Cover)
	elif _rescued < 6:
		disable_all($YSort/Level1Cover)
		disable_all($YSort/Level1Obstacles)
		disable_all($YSort/Level2Cover)
		disable_all($YSort/Level2Obstacles)
		enable_all($YSort/Level3Cover)
		enable_all($YSort/Level3Obstacles)
		disable_all($YSort/Level4Cover)
	elif _rescued < 8:
		disable_all($YSort/Level1Cover)
		disable_all($YSort/Level1Obstacles)
		disable_all($YSort/Level2Cover)
		disable_all($YSort/Level2Obstacles)
		disable_all($YSort/Level3Cover)
		disable_all($YSort/Level3Obstacles)
		enable_all($YSort/Level4Cover)
	
	# Clear dropped objects
	for cover in $YSort/DroppedCover.get_children():
		$YSort/DroppedCover.remove_child(cover)
		cover.queue_free()

func enable_all(node):
	for n in node.get_children():
		n.enable()

func disable_all(node):
	for n in node.get_children():
		n.disable()

func adjust_finger_difficulty():
	_fingers = $Fingers.get_children()
	for finger in _fingers:
		if _rescued < 2:
			finger.pursue_speed = 50.0
		elif _rescued < 4:
			finger.pursue_speed = 55.0
		elif _rescued < 6:
			finger.pursue_speed = 57.0
		elif _rescued < 8:
			finger.pursue_speed = 58.0

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
		var corpse = _corpse_scene.instance()
		corpse.configure(_player)
		corpse.position = _player.position
		$YSort.add_child(corpse)
		_player = null
	_goal_reached = false
	var spawn_point : Position2D = $SpawnPoints.get_child(randi() % $SpawnPoints.get_child_count())
	_player = _player_scene.instance()
	_player.set_position(spawn_point.position)
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
			fall_motion.x = -90
		elif which == "right":
			self.add_child_below_node($YSort, _player)
			fall_motion.x = 90
		_player.enter_fall_state(fall_motion)
		$RespawnTimer.start()

func disconnect_player_signals():
	_player.disconnect("entered_cover", self, "_player_entered_cover")
	_player.disconnect("exited_cover", self, "_player_exited_cover")
	_player.disconnect("killed", self, "_player_killed")

func connect_player_signals():
	_player.connect("entered_cover", self, "_player_entered_cover")
	_player.connect("exited_cover", self, "_player_exited_cover")
	_player.connect("entered_drop_zone", self, "_player_entered_drop_zone")
	_player.connect("exited_drop_zone", self, "_player_exited_drop_zone")
	_player.connect("killed", self, "_player_killed")

func _player_entered_cover() -> void:
	_abandon_all_pursuits()
	$YSort/DropShadow.set_target(null)

func _player_entered_drop_zone() -> void:
	_abandon_all_pursuits()
	if !_player.is_in_cover():
		$YSort/DropShadow.set_target(_player)

func _abandon_all_pursuits() -> void:
	for finger in _fingers:
		finger.abandon()

func _reset_all_fingers() -> void:
	for finger in _fingers:
		finger.reset()

func _player_exited_cover() -> void:
	# TODO: Might want to wait before activating a finger, but for now just doing it straight away
	# TODO: Need to make sure player is not in drop zone
	if !_player.is_in_drop_zone() and !_player.is_in_cover():
		var finger = _fingers[randi() % len(_fingers)]
		finger.pursue(_player)
	if _player.is_in_drop_zone():
		$YSort/DropShadow.set_target(_player)

func _player_exited_drop_zone() -> void:
	# TODO: Might want to wait before activating a finger, but for now just doing it straight away
	if !_player.is_in_drop_zone() and !_player.is_in_cover():
		var finger = _fingers[randi() % len(_fingers)]
		finger.pursue(_player)
	if !_player.is_in_drop_zone():
		$YSort/DropShadow.set_target(null)

func _player_killed() -> void:
	_abandon_all_pursuits()
	$YSort/DropShadow.set_target(null)
	_player_killed = true
	$CameraTarget.follow(null)
	$CameraTarget.shake(0.2)
	$RespawnTimer.start()

func _on_RespawnTimer_timeout():
	FadeMask.fade_in()

func _process(delta):
	if Input.is_action_just_pressed("increase_rescued") and DEBUG:
		_rescued += 1
		_configure_level()


func _on_DropShadow_drop_updated(pos, height):
	# Update the drop shadow to the specified position and height.
	# If a terminal drop is in progress then update that as well.
	#$YSort/DropShadow.centre_on_position(pos, height)
	if _current_drop_effect != null:
		_current_drop_effect.position = $YSort/DropShadow.position
		_current_drop_effect.set_height(height)


func _on_DropShadow_drop_completed(pos):
	# Kill player if they are within range of the drop position
	var player_vector = _player.position - pos
	if player_vector.length() < 40.0:
		_player.kill(player_vector)
	# Spawn cover object at position and hide shadow and drop object
	var cover_obj = _cover_object_scene.instance()
	cover_obj.position = Vector2(pos.x, pos.y - 36) # Magic number adjusts for offset of card cover object, to make it seem centred where the shadow was
	$YSort/DroppedCover.add_child(cover_obj)
	$YSort/DropShadow.hide()
	if _current_drop_effect != null:
		$YSort/DroppedCover.remove_child(_current_drop_effect)
		_current_drop_effect.queue_free()
		_current_drop_effect = null
	# Screen shake
	$CameraTarget.shake(0.2)
	# Play sound effect
	$DropSoundPlayer.play()
	
	


func _on_DropShadow_terminal_drop_initiated(pos, height):
	# Spawn or update terminal drop object
	_current_drop_effect = _drop_effect_scene.instance()
	$YSort/DroppedCover.add_child(_current_drop_effect)
	_current_drop_effect.position = pos
	_current_drop_effect.set_height(height)
