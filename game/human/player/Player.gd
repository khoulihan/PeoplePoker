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
var _was_running : bool
var _roll_vector : Vector2
var _rolling : bool
var _in_cover : bool = true
var _falling : bool
var _fall_motion : Vector2

onready var _input : InputController = $InputController

func _ready():
	_stamina = max_stamina

# TODO: The movement stuff should maybe be in physics_process...
func _process(delta):
	var recharge_stamina = true
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
					# TODO: Play animation
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
		var actual_movement : Vector2 = self.move_and_slide(requested_movement)
		
		if recharge_stamina:
			_stamina += stamina_recharge * delta
			if _stamina > max_stamina:
				_stamina = max_stamina
	elif _falling:
		_fall_motion.y += 10.0
		self.position += _fall_motion * delta

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
	return self.position + (self._last_movement * run_speed * 0.5)

func kill():
	_alive = false
	$AnimationPlayer.play("Death")
	emit_signal("killed")