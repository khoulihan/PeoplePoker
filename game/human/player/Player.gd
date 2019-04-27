extends "res://game/human/Human.gd"

const InputController = preload("res://game/human/player/InputController.gd")

export(float) var max_stamina
export(float) var roll_speed
export(float) var run_stamina_drain
export(float) var stamina_recharge

var _alive : bool = true
var _stamina : float

var _last_movement : Vector2
var _was_running : bool
var _roll_vector : Vector2
var _rolling : bool

onready var _input : InputController = $InputController

func _ready():
	_stamina = max_stamina

func _process(delta):
	var recharge_stamina = true
	if _alive:
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
					self.position += movement_input * self.walk_speed * delta
					if _facing_front(movement_input):
						$AnimationPlayer.play("WalkFront")
					else:
						$AnimationPlayer.play("WalkBack")
				else:
					recharge_stamina = false
					_was_running = true
					_stamina -= run_stamina_drain * delta
					self.position += movement_input * self.run_speed * delta
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
				if _facing_front(_last_movement):
					$AnimationPlayer.play("IdleOpenFront")
				else:
					$AnimationPlayer.play("IdleOpenBack")
		
		if _rolling:
			recharge_stamina = false
			self.position += _roll_vector * self.roll_speed * delta
		
		if recharge_stamina:
			_stamina += stamina_recharge * delta
			if _stamina > max_stamina:
				_stamina = max_stamina

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