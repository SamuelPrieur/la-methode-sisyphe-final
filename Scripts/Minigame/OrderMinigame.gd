extends Node2D

signal mini_game_completed(success: bool)

var target_order = []
var current_index = 0
var error_count = 0
var buttons = []
var audio_player_order

func _ready():
	# ----------------------- Préparation de l'audio ----------------------- #
	audio_player_order = AudioStreamPlayer.new()
	add_child(audio_player_order)
	audio_player_order.stream = load("res://Assets/Audio/Action/OrderMinigame.wav")
	audio_player_order.volume_db = -15
	
	# ----------------------- Connecter les boutons ----------------------- #
	for i in range(1, 11):
		var button = get_node("OrderButton%d" % i)
		buttons.append(button)
		button.pressed.connect(_on_button_pressed.bind(i))
	
	reset_game()

# ----------------------- Gestion : Boutons ----------------------- #
func _on_button_pressed(button_number: int):
	audio_player_order.play()
	if current_index >= target_order.size():
		return
		
	if target_order[current_index] == button_number:
		current_index += 1
		if current_index >= target_order.size():
			emit_signal("mini_game_completed", true)
			if Global.reactorState == "Allumé":
				Global.reactorState = "Éteint"
			else: 
				Global.reactorState = "Allumé"
			return
	else:
		error_count += 1
		emit_signal("mini_game_completed", false)

# ----------------------- Reset du Mini jeu ----------------------- #
func reset_game():
	current_index = 0
	error_count = 0
	
	# Définir l'ordre selon l'état des moteurs
	if Global.reactorState == "Allumé":
		# Ordre décroissant pour éteindre les moteurs
		target_order = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
	else:
		# Ordre croissant pour allumer les moteurs
		target_order = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# faire une nouvelle classe pour les boutons, et switch entre les deux états, au chargement de la tache en fonction de si le réacteur est allumé, changer le sprite de tout les boutons
