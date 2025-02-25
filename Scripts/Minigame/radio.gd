extends Node2D

@onready var hz_slider = $HzSlider
@onready var right_radio = $RightRadio
@onready var left_radio = $LeftRadio
@onready var hz_label = $HzLabel

signal mini_game_completed(success: bool)

var audio_left_radio
var audio_right_radio
var target_frequency = 0
# Marge d'erreur (dans le doute)
var frequency_tolerance = 5

var validation_timer: Timer
var is_frequency_correct = false

func _ready():

	# ----------------------- Préparation de l'audio ----------------------- #

	audio_left_radio = AudioStreamPlayer.new()
	audio_right_radio = AudioStreamPlayer.new()
	
	add_child(audio_left_radio)
	add_child(audio_right_radio)
	
	audio_right_radio.stream = load("res://Assets/Audio/Action/RadioRight.wav")
	audio_left_radio.stream = load("res://Assets/Audio/Action/RadioLeft.wav")
	
	audio_right_radio.volume_db = -15
	audio_left_radio.volume_db = -15

	# ----------------------- Connecter les boutons ----------------------- #

	right_radio.pressed.connect(_on_right_radio_pressed)
	left_radio.pressed.connect(_on_left_radio_pressed)
	
	# ----------------------- Connecter le slider ----------------------- #

	hz_slider.value_changed.connect(_on_slider_value_changed)
	
	validation_timer = Timer.new()
	validation_timer.wait_time = 0.5  
	validation_timer.one_shot = true
	validation_timer.timeout.connect(_on_validation_timer_timeout)
	add_child(validation_timer)
	
	update_Hz()

# ----------------------- Gestion : Bouton Droite ----------------------- #

func _on_right_radio_pressed():
	hz_slider.value += 75
	audio_right_radio.play()
	check_frequency()

# ----------------------- Gestion : Bouton Gauche ----------------------- #

func _on_left_radio_pressed():
	hz_slider.value -= 75
	audio_left_radio.play()
	check_frequency()

# ----------------------- Gestion : Modif des Hz ----------------------- #

func _on_slider_value_changed(_value: float):
	update_Hz()
	check_frequency()

# ----------------------- Gestion : Label Hz ----------------------- #

func update_Hz():
	hz_label.text = str(hz_slider.value) + " Hz"

# ----------------------- Gestion : Slider Hz ----------------------- #

func set_target_frequency(freq: int):
	target_frequency = freq

# ----------------------- Gestion : Vérification des Hz ----------------------- #

func check_frequency():
	var current_freq = hz_slider.value
	var is_in_range = abs(current_freq - target_frequency) <= frequency_tolerance
	
	if is_in_range:
		if !is_frequency_correct:
			is_frequency_correct = true
		validation_timer.start()  
	else:
		if is_frequency_correct:
			is_frequency_correct = false
			validation_timer.stop()


# ----------------------- Fin du timer et Validation du Mini Jeu ----------------------- #

func _on_validation_timer_timeout():
	if is_frequency_correct:
		emit_signal("mini_game_completed", true)

# ----------------------- Reset du Mini jeu ----------------------- #

func reset_game():
	hz_slider.value = 300  # Valeur de départ
	is_frequency_correct = false
	validation_timer.stop()
	update_Hz()
