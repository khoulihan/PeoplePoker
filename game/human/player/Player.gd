extends "res://game/human/Human.gd"

const InputController = preload("res://game/human/player/InputController.gd")

export(float) var max_stamina
export(float) var roll_speed
export(float) var run_stamina_drain
export(float) var stamina_recharge

signal entered_cover
signal exited_cover
signal killed

var _alive : bool = true
var _stamina : float

var _last_movement : Vector2
var _last_actual_movement : Vector2
var _was_running : bool
var _roll_vector : Vector2
var _rolling : bool
var _in_cover : bool = true
var _falling : bool
var _fall_motion : Vector2
var _death_motion : Vector2
var _true_position : Vector2

onready var _input : InputController = $InputController

func _ready():
	_stamina = max_stamina

func _physics_process(delta):
	var recharge_stamina = true
	self.position = _true_position
	if _alive and !_falling:
		var requested_movement : Vector2 = Vector2(0,0)
		var movement_input = _input.get_movement()
		if movement_input.length_squared() > 0.2:
			if !_rolling:
				var roll : bool = _input.get_roll()
				if roll and _stamina > (max_stamina * 0.75):
					# Roll requested and granted!
					_roll_vector = movement_input
					_rolling = true
					_stamina = 0.0
					$RollTimer.start()
					if _facing_front(movement_input):
						$AnimationPlayer.play("RollFront")
					else:
						$AnimationPlayer.play("RollBack")
				elif roll:
					# roll requested but denied
					# TODO: Feedback
					pass
					
			if !_rolling:
				_set_flip_h(_facing_left(movement_input))
				var run : bool = _input.get_run()
				if !run or !_can_run():
					_was_running = false
					requested_movement = movement_input * self.walk_speed
					if _facing_front(movement_input):
						$AnimationPlayer.play("WalkFront")
					else:
						$AnimationPlayer.play("WalkBack")
				else:
					recharge_stamina = false
					_was_running = true
					_stamina -= run_stamina_drain * delta
					requested_movement = movement_input * self.run_speed
					if _facing_front(movement_input):
						$AnimationPlayer.play("RunFront")
					else:
						$AnimationPlayer.play("RunBack")
					
			_last_movement = movement_input
		else:
			# Idle (unless rolling)
			if !_rolling:
				_set_flip_h(_facing_left(_last_movement))
				# TODO: This will have to vary based on cover state
				# NOTE: I believe this will not restart currently running animations, if it does, then... problems
				$AnimationPlayer.play(_idle_animation(_last_movement))
		
		if _rolling:
			recharge_stamina = false
			requested_movement = _roll_vector * self.roll_speed
		
		# Action the movement
		var final_movement = Vector2(
			ceil(abs(requested_movement.x)) * sign(requested_movement.x),
			ceil(abs(requested_movement.y)) * sign(requested_movement.y)
		)
		var actual_movement : Vector2 = self.move_and_slide(final_movement)
		_last_actual_movement = actual_movement
		
		if recharge_stamina:
			_stamina += stamina_recharge * delta
			if _stamina > max_stamina:
				_stamina = max_stamina
	elif _falling:
		_fall_motion.y += 10.0
		self.position += _fall_motion * delta
	else:
		if _death_motion.length() > 0.5:
			self.move_and_slide(_death_motion)
			_death_motion = _death_motion * 0.9
		else:
			_death_motion = Vector2(0.0, 0.0)
			self.position = Vector2(floor(self.position.x), floor(self.position.y))
	
	_true_position = self.position

# TODO: The movement stuff should maybe be in physics_process...
func _process(delta):
	self.position = Vector2(round(_true_position.x), round(_true_position.y))

func set_position(p : Vector2) -> void:
	_true_position = p
	self.position = Vector2(round(_true_position.x), round(_true_position.y))

func get_stamina() -> float:
	return _stamina

func is_alive() -> bool:
	return _alive

func _idle_animation(movement) -> String:
	if _facing_front(movement):
		return "IdleCoverFront" if _in_cover else "IdleOpenFront"
	else:
		return "IdleCoverBack" if _in_cover else "IdleOpenBack"

func _can_run() -> bool:
	if _was_running and _stamina > 0.0:
		return true
	else:
		return _stamina > (max_stamina * 0.25)

func _facing_left(movement) -> bool:
	return movement.x < 0.0

func _facing_front(movement) -> bool:
	return movement.y > -0.1

func _set_flip_h(f) -> void:
	$Male.flip_h = f
	$Female.flip_h = f

func enter_cover() -> void:
	_in_cover = true
	emit_signal("entered_cover")

func exit_cover() -> void:
	_in_cover = false
	emit_signal("exited_cover")

func disable_collider() -> void:
	$CollisionShape2D.disabled = true

func enter_fall_state(fall_motion) -> void:
	_falling = true
	_fall_motion = fall_motion
	if _last_movement.y < 0:
		$AnimationPlayer.play("JumpBack")
	else:
		$AnimationPlayer.play("JumpFront")

func position_prediction() -> Vector2:
	#return self.position + (self._last_movement * walk_speed * (1.0/60.0) * 4.0)
	return self.position + (self._last_actual_movement * 0.4)

func get_last_actual_movement() -> Vector2:
	return _last_actual_movement

func kill(direction : Vector2) -> void:
	_alive = false
	print(direction)
	_death_motion = (direction.normalized() + (_last_actual_movement.normalized() * 0.5)).normalized() * 200.0
	if _facing_front(_death_motion):
		$AnimationPlayer.play("DeathFront")
	else:
		$AnimationPlayer.play("DeathBack")
	emit_signal("killed")

func _on_RollTimer_timeout():
	_rolling = false

func _on_footstep():
	$FootstepAudioStreamPlayer.play()
