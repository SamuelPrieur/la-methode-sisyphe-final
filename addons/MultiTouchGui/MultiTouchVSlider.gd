extends VSlider
class_name MultiTouchVSlider

var audio_player
var sound_1
var sound_2
var old_value  

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = -15

	sound_1 = load("res://Assets/Audio/Action/TickSlider1.wav")
	sound_2 = load("res://Assets/Audio/Action/TickSlider2.wav")

	old_value = int(value)

func _gui_input(event):
	var event_pos_adjusted = event.position + global_position
	var inside = event_pos_adjusted.x > position.x and event_pos_adjusted.y > position.y and event_pos_adjusted.x < position.x + size.x and event_pos_adjusted.y < position.y + size.y

	if event is InputEventScreenTouch and event.pressed and inside:
		return
	
	if event is InputEventScreenDrag and inside:
		if int(value) != old_value:  
			audio_player.stream = sound_1 if randi() % 2 == 0 else sound_2
			audio_player.play()

			old_value = int(value)
