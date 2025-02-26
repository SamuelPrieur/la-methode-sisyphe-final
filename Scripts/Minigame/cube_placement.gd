extends Node2D

signal mini_game_completed(success: bool)

@onready var cube = $Cube
@onready var up_button = $UpButton
@onready var right_button = $RightButton
@onready var left_button = $LeftButton
@onready var down_button = $DownButton

# Aléatoire
var rng = RandomNumberGenerator.new()
# Pour valider le mini jeu
var is_centered = false
# Audio
var audio_player_cube

func _ready():
	var main_game = null  
	match Global.player_number:
		1:
			main_game = get_node_or_null("/root/Panel/TaskManager")
		2:
			main_game = get_node_or_null("/root/Panel/TaskManagerTwo")
	
	if main_game:
		main_game.cube_minigame_selected.connect(randomize_position)
	
	# ----------------------- Préparation de l'audio ----------------------- #
	
	audio_player_cube = AudioStreamPlayer.new()
	add_child(audio_player_cube)
	audio_player_cube.stream = load("res://Assets/Audio/Action/BeepCenterMinigame.wav")
	audio_player_cube.volume_db = -15
	
	# ----------------------- Connecter les boutons ----------------------- #

	up_button.pressed.connect(move_up)
	right_button.pressed.connect(move_right)
	left_button.pressed.connect(move_left)
	down_button.pressed.connect(move_down)
	
	randomize_position()

# ----------------------- Chaque delta temps on appelle la fonction ----------------------- #

func _process(_delta):
	check_if_centered()

# ----------------------- Position aléatoire ----------------------- #

func randomize_position():
	var random_x = 0
	var random_y = 0
	
	# Relance le tirage si l'une des valeurs est inférieure à 30
	while abs(random_x) < 30 or abs(random_y) < 30:
		random_x = rng.randi_range(-130, 130)
		random_y = rng.randi_range(-100, 100)
	
	cube.position = Vector2(random_x, random_y)

# ----------------------- Gestion : Bouton Haut ----------------------- #

func move_up():
	audio_player_cube.play()
	var temp = cube.position.y - 20
	if temp >= -100:
		cube.position.y -= 20

# ----------------------- Gestion : Bouton Bas ----------------------- #

func move_down():
	audio_player_cube.play()
	var temp = cube.position.y + 20
	if temp <= 100:
		cube.position.y += 20

# ----------------------- Gestion : Bouton Gauche ----------------------- #

func move_left(): 
	audio_player_cube.play()
	var temp = cube.position.x - 20
	if temp >= -100:
		cube.position.x -= 20

# ----------------------- Gestion : Bouton Droite ----------------------- #

func move_right():
	audio_player_cube.play()
	var temp = cube.position.x + 20
	if temp <= 100:
		cube.position.x += 20

# ----------------------- Vérifier la position du cube ----------------------- #

func check_if_centered():
	var margin = 19
	
	if abs(cube.position.x) <= margin and abs(cube.position.y) <= margin:
		if not is_centered:
			emit_signal("mini_game_completed", true)
			is_centered = true
			return
	else:
		is_centered = false
