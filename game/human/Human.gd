extends KinematicBody2D

export(int, "Male", "Female") var sex : int
export(float) var walk_speed
export(float) var run_speed
export(bool) var always_speak
export(bool) var speak
export(String, MULTILINE) var phrases
export(int) var speak_chance

signal speak(speech)

var _phrases : PoolStringArray

var _back : bool
var _player
var _speaking : bool = false

func _ready():
	_phrases = phrases.split("\n")


func configure(player):
	_player = player
	var skin = randi() % 3
	_back = (randi() % 2 == 0)
	var flip = (randi() % 2 == 0)
	
	# TODO: Duplicating the materials probably only needs to be done the first time
	if self.sex == 0:
		$Female.visible = false
		$Male.visible = true
		$Male.material = $Male.material.duplicate(true)
		$Male.material.set_shader_param("skin_type", skin)
		$Male.flip_h = flip
	else:
		$Male.visible = false
		$Female.visible = true
		$Female.material = $Female.material.duplicate(true)
		$Female.material.set_shader_param("skin_type", skin)
		$Female.flip_h = flip
	
	if _back:
		$AnimationPlayer.play("IdlePenBack")
	else:
		$AnimationPlayer.play("IdlePenFront")
	$AnimationPlayer.seek(rand_range(0.0, $AnimationPlayer.get_animation("IdlePenFront").length), true)
	
	if always_speak:
		speak()


func _process(delta):
	if _player != null:
		var targetVector : Vector2 = self.position - _player.position
		var angle : float = targetVector.angle()
		var flip = false
		if angle > 0.0:
			$AnimationPlayer.play("IdlePenBack")
			if angle < PI / 2.0:
				flip = true
		else:
			$AnimationPlayer.play("IdlePenFront")
			if angle > -PI / 2.0:
				flip = true
		$Male.flip_h = flip
		$Female.flip_h = flip
	if speak and !_speaking:
		if randi() % speak_chance == 0:
			speak()

func speak() -> void:
	_speaking = true
	emit_signal("speak", _phrases[randi() % _phrases.size()])

func on_speech_timed_out():
	_speaking = false
