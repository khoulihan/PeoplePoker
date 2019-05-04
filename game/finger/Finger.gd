extends Node2D

const vertical_texture = preload("res://game/finger/FingerVertical.png")

#export(int, "Horizontal", "Vertical") var orientation
#export(bool) var reverse # Coming in from the left or up from the bottom are the defaults

var _original_position : Vector2

export(float) var pursue_speed : float = 50.0
export(float) var retreat_speed : float = 40.0
export(float) var attack_speed : float = 150.0
export(float) var attack_distance : float = 40.0
export(float) var achieved_distance : float = 10.0

signal attack_complete

var _player : Node2D
var _attack : bool
var _attack_position : Vector2

func _ready():
	configure()

func configure():
	_original_position = self.position
#	var original_offset = $Sprite.offset
#	if orientation == 1:
#		$Sprite.texture = vertical_texture
#		$Sprite.offset.x = original_offset.y
#		$Sprite.offset.y = original_offset.x
#	if reverse:
#		if orientation == 0:
#			$Sprite.flip_h = true
#			$Sprite.offset.x = 15
#		else:
#			$Sprite.flip_v = true
#			$Sprite.offset.y = -15

func pursue(player) -> void:
	_player = player

func abandon() -> void:
	_player = null
	_attack = false

func reset() -> void:
	self.position = _original_position

func _process(delta):
	var global_pos = self.global_position
	if _player != null:
		# Pursue / attack
		if !_attack:
			var pursue_vector : Vector2 = (_player.global_position - self.global_position)
			if pursue_vector.length() > attack_distance:
				#print (pursue_vector)
				var pursue_translation = pursue_vector.normalized() * pursue_speed * delta
				self.global_translate(pursue_translation)
			else:
				_attack = true
				# TODO: This doesn't work because of how the fingers are attached to the camera
				_attack_position = _player.position_prediction()
		if _attack:
			var attack_vector : Vector2 = (_attack_position - self.global_position)
			var attack_translation = attack_vector.normalized() * attack_speed * delta
			if attack_vector.length() < attack_translation.length():
				self.global_translate(attack_vector)
				print ("Abandoning")
				abandon()
				emit_signal("attack_complete")
			else:
				self.global_translate(attack_translation)
			#if (_attack_position - self.global_position).length() < achieved_distance:
			#	abandon()
			#	emit_signal("attack_complete")
	else:
		# TODO: Could cut out some work here by deativating once original position is reached
		# Retreat
		var retreat_vector : Vector2 = (_original_position - self.position)
		#var retreat_direction : Vector2 = retreat_vector.normalized()
		var retreat = retreat_vector.normalized() * retreat_speed * delta
		if retreat.length_squared() > retreat_vector.length_squared():
			self.position = _original_position
		else:
			self.translate(retreat)
		

func _on_Area2D_body_entered(body):
	if body == _player:
		_player.kill()
		abandon()
