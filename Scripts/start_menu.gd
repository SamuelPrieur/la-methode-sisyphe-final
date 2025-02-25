extends Control

@onready var light_tv = $LightTV
@onready var start_button = $StartButton  
@onready var exit_button = $ExitButton
@onready var mode_1_button = $OnePlayerMode
@onready var mode_2_button = $TwoPlayerMode
@onready var mode_1_label = $OnePlayerLabel
@onready var mode_2_label = $TwoPlayerLabel
@onready var return_button = $Return
@onready var player = $Player
@onready var player2 = $Player2
@onready var player3 = $Player3

var audio_player
var accumulated_time = 0.0
var next_change_time = 0.0
var action_to_perform = null
var selected_mode = null

func _ready():
	Global.score = 0
	Global.level = 1
	_generate_next_change_time()

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = -10
	audio_player.stream = load("res://Assets/Audio/Action/Menu.wav")
	audio_player.finished.connect(_on_audio_finished)

	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	mode_1_button.pressed.connect(_on_mode_1_pressed)
	mode_2_button.pressed.connect(_on_mode_2_pressed)
	return_button.pressed.connect(_on_return_pressed)

	mode_1_button.visible = false
	mode_2_button.visible = false
	mode_1_label.visible = false
	mode_2_label.visible = false
	return_button.visible = false
	
	player.visible = false
	player2.visible = false
	player3.visible = false

# ----------------------- Animation de la TV ----------------------- #
func _process(delta):
	accumulated_time += delta

	if accumulated_time >= next_change_time:
		accumulated_time = 0.0  
		_generate_next_change_time()  
		light_tv.energy = randf_range(5,6)  

func _generate_next_change_time():
	next_change_time = randf_range(0.1, 0.2)

# ----------------------- Gestion : Boutons ----------------------- #
func _on_start_button_pressed():
	audio_player.play()
	mode_1_button.visible = true
	mode_2_button.visible = true
	mode_1_label.visible = true
	mode_2_label.visible = true
	return_button.visible = true 
	
	player.visible = true
	player2.visible = true
	player3.visible = true
	
	start_button.visible = false
	exit_button.visible = false
	
func _on_return_pressed():
	audio_player.play()
	mode_1_button.visible = false
	mode_2_button.visible = false
	mode_1_label.visible = false
	mode_2_label.visible = false
	return_button.visible = false 
	
	player.visible = false
	player2.visible = false
	player3.visible = false
	
	start_button.visible = true
	exit_button.visible = true

func _on_exit_button_pressed():
	audio_player.play()
	action_to_perform = "quit"

# ----------------------- Sélection du mode de jeu ----------------------- #
func _on_mode_1_pressed():
	audio_player.play()
	Global.player_number = 1
	action_to_perform = "change_scene"

func _on_mode_2_pressed():
	audio_player.play()
	Global.player_number = 2
	action_to_perform = "change_scene"

# ----------------------- Gestion : Audio terminé ----------------------- #
func _on_audio_finished():
	if action_to_perform == "change_scene":
		get_tree().change_scene_to_file("res://Scenes/LevelTransition.tscn")
	elif action_to_perform == "quit":
		get_tree().quit()
