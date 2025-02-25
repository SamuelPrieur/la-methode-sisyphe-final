extends Node2D

signal mini_game_completed(success: bool)

# Audio
var button_click
var minigame_success

var color_buttons = []
var pattern = []
var user_index = 0
var pattern_delay = 0.5
var _pattern_en_cours = false
var niveau = 1
var boutons_actifs = 3

func _ready():


		
# ----------------------- Préparation de l'audio ----------------------- #
	button_click = AudioStreamPlayer.new()
	minigame_success = AudioStreamPlayer.new()

	add_child(button_click)
	add_child(minigame_success)

	button_click.stream = load("res://Assets/Audio/Action/Simon/click.wav")
	minigame_success.stream = load("res://Assets/Audio/Action/Simon/success.wav")

	button_click.volume_db = -15
	minigame_success.volume_db = -15


	randomize()
	for i in range(1, 13):  
		var btn = get_node("ColorButton" + str(i)) as MultiTouchButton
		color_buttons.append(btn)
		btn.pressed.connect(func(): _on_ColorButton_pressed(i - 1))  
	
	var main_game = get_node("/root/Panel/TaskManagerTwo")
	if main_game:
		await main_game.simon_minigame_selected.connect(clignoter_tous_les_boutons)
		

func clignoter_tous_les_boutons():
	_pattern_en_cours = true
	for _i in range(4):  
		for btn in color_buttons:
			btn.icon = btn.icon_pressed
		await get_tree().create_timer(0.2).timeout
		for btn in color_buttons:
			btn.icon = btn.icon_normal
		await get_tree().create_timer(0.2).timeout
	commencer_jeu()

func commencer_jeu():
	pattern.clear()
	user_index = 0
	
	match Global.level:
		1:
			boutons_actifs = 3
		2:
			boutons_actifs = 3
		3:
			boutons_actifs = 4
		4:
			boutons_actifs = 6
		5:
			boutons_actifs = 6

	for _i in range(boutons_actifs):
		ajouter_etape()
	
	afficher_pattern()

func ajouter_etape():
	var bouton_choisi = randi() % 12  
	pattern.append(bouton_choisi)

func afficher_pattern():
	_pattern_en_cours = true
	user_index = 0
	for index in pattern:
		await _flash_button(index)
		await get_tree().create_timer(pattern_delay).timeout
	_pattern_en_cours = false

func _flash_button(btn_index) -> void:
	var btn = color_buttons[btn_index]
	btn.icon = btn.icon_pressed
	await get_tree().create_timer(0.5).timeout
	btn.icon = btn.icon_normal

func _on_ColorButton_pressed(btn_index):
	button_click.play()
	if _pattern_en_cours:
		return

	if user_index >= pattern.size():
		return

	if pattern[user_index] == btn_index:
		user_index += 1
		if user_index >= pattern.size():
			minigame_success.play()
			emit_signal("mini_game_completed", true)
	else:
		emit_signal("mini_game_completed", false)
