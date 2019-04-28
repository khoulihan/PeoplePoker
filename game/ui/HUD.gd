extends CanvasLayer

var _player
var _rescued = 0

func _ready():
	pass

func _process(delta):
	if _player != null and _player.is_alive():
		$MarginContainer/VBoxContainer/StaminaLabel.text = "Stamina: %d" % floor(_player.get_stamina())
	else:
		$MarginContainer/VBoxContainer/StaminaLabel.text = ""
	$MarginContainer/VBoxContainer/RescuedLabel.text = "Rescued: %d" % _rescued


func _on_Game_rescued_updated(new_total):
	_rescued = new_total



func _on_Game_player_spawned(new_player):
	_player = new_player
