extends Node

signal task_completed(task_name: String)
signal new_task_started(task_name: String)
signal task_failed(task_name: String)
signal cube_minigame_selected
signal rotation_minigame_selected
signal simon_minigame_selected
signal order_minigame_selected
signal signal_minigame_selected



# Audio
var audio_player_alarm
var audio_player_button

# Progress Bar
@onready var progress_bar = $ProgressBar
var initial_time = 0.0

# Task
var current_task = null
var last_completed_task_id = null
var error_counter = 0
var task_timer: Timer

# Caméra et Shake
@onready var camera = get_node("/root/Panel/Camera2D")  
var accumulated_time = 0.0
var shake_intensity = 0
var shake_duration = 0
var shake_timer = 0

# Fiesta
var light_energy = 0.1
var disco_light_hue = 0.0
var fiesta = false
var target_y = -200.0
var default_y = 150.0  

# Mini jeu ordre croissant
@onready var order_minigame_scene = load("res://Scenes/Minigame/Order.tscn")
var order_minigame_instance = null

# Signal
var target_signal: String = ""




var available_tasks = [
	# Boutons
	{"id": "Button1", "description": "Monter de vitesse", "button_node": "Button1", "time_allowed": "8"},
	{"id": "Button2", "description": "Baisser de vitesse", "button_node": "Button2", "time_allowed": "8"},
	{"id": "Alternateur", "description": "Activer l'alternateur", "description_on": "Désactiver l'alternateur", "description_off": "Activer l'alternateur", "button_node": "Alternateur", "time_allowed": "8"},
	{"id": "Plasma", "description": "Activer le plasma", "description_on": "Désactiver le plasma", "description_off": "Activer le plasma", "button_node": "Plasma", "time_allowed": "8"},

	
	# Sliders
	{"id": "MultiTouchVSlider", "description": "Mettre le Slider rouge sur %d", "button_node": "Slider1", "possible_values": [0, 1, 2, 3], "time_allowed": "10"},
	
	# Order
	{"id": "OrderMinigame", "description": "Appuyer sur les boutons dans l'ordre", "description_on": "Éteindre les réacteurs dans l'ordre", "description_off": "Allumez les réacteurs dans l'ordre", "button_node": "OrderMinigame", "time_allowed": "20"},
	
	# Radio
	{"id": "RadioMinigame", "description": "Mettez la radio sur la fréquence %d Hz", "button_node": "RadioMinigame", "possible_values": [300,375,450,525,600,675,750,825,900], "time_allowed": "20"},
	
	# Signal
	{"id": "Signal", "description": "Changer l'oscillation du signal sur ","signal": ["Mars","Lune","Brésil","Alpha","Tango","Quebec"], "button_node": "CurveMinigame", "time_allowed": "20"},

]



func _ready():
	# ----------------------- Préparation de l'audio ----------------------- #
	audio_player_alarm = AudioStreamPlayer.new()
	audio_player_button = AudioStreamPlayer.new()

	add_child(audio_player_alarm)
	add_child(audio_player_button)

	audio_player_alarm.stream = load("res://Assets/Audio/Event/Alarm.wav")
	audio_player_button.stream = load("res://Assets/Audio/Action/Button.wav")

	audio_player_alarm.volume_db = -15
	audio_player_button.volume_db = -15
	
	# ----------------------- Préparation des Mini Jeux ----------------------- #

	for task in available_tasks:
		var node = get_node(task["button_node"])
		if node is MultiTouchButton or node is MultiTouchLevierPlasma or node is MultiTouchLevierAlternateur:
			node.pressed.connect(_on_button_pressed.bind(task["id"]))
		elif task["id"] == "OrderMinigame" :
			continue
		elif task["id"] == "Signal":
			continue
		elif task["id"] == "RadioMinigame":
			var radio_node = get_node(task["button_node"])
			radio_node.mini_game_completed.connect(_on_radio_mini_game_completed.bind(task))
		elif task["id"] == "MultiTouchVSlider":
			node.drag_ended.connect(_on_slider_drag_ended.bind(task))

	# ----------------------- Création du timer ----------------------- #

	task_timer = Timer.new()
	task_timer.one_shot = true
	task_timer.timeout.connect(_on_task_timeout)
	add_child(task_timer)
	await get_tree().create_timer(0.1).timeout

	# ----------------------- Début du jeu ----------------------- #

	start_random_task()

# ----------------------- Changer l'état de la lumière pendant la tache ----------------------- #

func hold_light():
	await get_tree().create_timer(0.5).timeout
	Global.lightState = "Hold"

# ----------------------- Commencer une nouvelle tache aléatoire ----------------------- #

func start_random_task():
	# Réinitialisation de la lumières
	hold_light()
	# Nouvelle tache aléatoire, obligatoirement différente de la dernière
	var available_choices = available_tasks.filter(func(task): return task["id"] != last_completed_task_id)
	current_task = available_choices[randi() % available_choices.size()]

	task_timer.stop()
	initial_time = float(current_task["time_allowed"])
	task_timer.wait_time = initial_time
	progress_bar.max_value = initial_time
	progress_bar.value = initial_time
	task_timer.start()
	
	# ----------------------- Lancer le bon Mini Jeu ----------------------- #

	if current_task["id"] == "OrderMinigame":
		var task_description = current_task["description"]

		if "description_on" in current_task and "description_off" in current_task:
			if Global.reactorState == "Allumé":
				task_description = current_task["description_on"]
			else:
				task_description = current_task["description_off"]

		new_task_started.emit(task_description)
		start_order_minigame()
		return

	if current_task["id"] == "Signal":
		signal_minigame_selected.emit()
		start_signal_minigame()
		return

	if current_task["id"] == "Alternateur":
		var task_description = current_task["description"]

		if "description_on" in current_task and "description_off" in current_task:
			if Global.alternateur == "on":
				task_description = current_task["description_on"]
			else:
				task_description = current_task["description_off"]

		new_task_started.emit(task_description)
		return

	if current_task["id"] == "Plasma":
		var task_description = current_task["description"]

		if "description_on" in current_task and "description_off" in current_task:
			if Global.plasma == "on":
				task_description = current_task["description_on"]
			else:
				task_description = current_task["description_off"]

		new_task_started.emit(task_description)
		return
	
	# Si c'est un slider :
	if "possible_values" in current_task:
		var node = get_node(current_task["button_node"])
		var current_value
		
		if current_task["id"] == "RadioMinigame":
			current_value = int(node.get_node("HzSlider").value)
			var random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			while random_value == current_value:
				random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			
			current_task["target_value"] = random_value
			node.set_target_frequency(current_task["target_value"])
		
		else:
			current_value = int(node.value)
			var random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			while random_value == current_value:
				random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			
			current_task["target_value"] = random_value
		new_task_started.emit(current_task["description"] % current_task["target_value"])
	else:
		new_task_started.emit(current_task["description"])
	

# ----------------------- Damage -> Animation de la caméra ----------------------- #

func shake_screen(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	if shake_timer > 0:
		# Déplacement aléatoire de la caméra
		var offset_x = randf_range(-shake_intensity, shake_intensity)
		var offset_y = randf_range(-shake_intensity, shake_intensity)
		camera.offset = Vector2(offset_x, offset_y)



func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		if shake_timer <= 0:
			camera.offset = Vector2.ZERO
		else:
			var offset_x = randf_range(-shake_intensity, shake_intensity)
			var offset_y = randf_range(-shake_intensity, shake_intensity)
			camera.offset = Vector2(offset_x, offset_y)
	
	if task_timer.time_left > 0:
		progress_bar.value = task_timer.time_left
		var time_ratio = task_timer.time_left / initial_time

		if time_ratio <= 0.50:
			if not audio_player_alarm.playing:
				audio_player_alarm.play()
			Global.lightState = "Error"
		else:
			audio_player_alarm.stop()

# ----------------------- Condition : boutons et slider simples ----------------------- #

func _on_button_pressed(task_id: String):
	audio_player_button.play()
	if current_task and task_id == current_task["id"]:
		complete_current_task()

func _on_slider_drag_ended(value_changed: bool, task: Dictionary):
	if value_changed: # Si la valeur a changé pendant le drag
		var node = get_node(task["button_node"])
		var value = node.value # On récupère la valeur actuelle du slider
		if current_task and current_task["button_node"] == task["button_node"] and value == current_task["target_value"]:
			complete_current_task()
			
# ----------------------- Condition : Mini jeu ordre croissant ----------------------- #

func start_order_minigame():
	var order_minigame = get_node("OrderMinigame")
	order_minigame_selected.emit()
	order_minigame.mini_game_completed.connect(_on_order_minigame_completed)
	order_minigame.reset_game()
	
	task_timer.stop()
	initial_time = float(current_task["time_allowed"])
	task_timer.wait_time = initial_time
	progress_bar.max_value = initial_time
	progress_bar.value = initial_time
	task_timer.start()

func _on_order_minigame_completed(success: bool):
	var order_minigame = get_node("OrderMinigame")
	order_minigame.mini_game_completed.disconnect(_on_order_minigame_completed)
	if success:
		complete_current_task()
	else:
		error_counter += 1
		task_failed.emit(current_task["id"])
		start_random_task()

# ----------------------- Condition : Mini jeu radio ----------------------- #

func _on_radio_mini_game_completed(success: bool, task):
	if success and current_task["id"] == task["id"]:
		complete_current_task()

# ----------------------- Condition : Mini jeu Signal ----------------------- #

func _on_signal_selected(signal_name: String):
	target_signal = signal_name

func start_signal_minigame():

	var signal_minigame = get_node("CurveMinigame")

	if signal_minigame.signal_selected.is_connected(_on_signal_selected):
		signal_minigame.signal_selected.disconnect(_on_signal_selected)

	signal_minigame.signal_selected.connect(_on_signal_selected)
	signal_minigame_selected.emit()
	
	await get_tree().create_timer(0.1).timeout
		
	new_task_started.emit(current_task["description"] + target_signal)
		
		
	if signal_minigame.mini_game_completed.is_connected(_on_signal_minigame_completed):
		signal_minigame.mini_game_completed.disconnect(_on_signal_minigame_completed)
		
	signal_minigame.mini_game_completed.connect(_on_signal_minigame_completed)
	
	task_timer.stop()
	initial_time = float(current_task["time_allowed"])
	task_timer.wait_time = initial_time
	progress_bar.max_value = initial_time
	progress_bar.value = initial_time
	task_timer.start()


func _on_signal_minigame_completed(success: bool):
	var signal_minigame = get_node("CurveMinigame")
	
	if current_task and current_task["id"] == "Signal":
		if signal_minigame.mini_game_completed.is_connected(_on_signal_minigame_completed):
			signal_minigame.mini_game_completed.disconnect(_on_signal_minigame_completed)
		
		if success:
			complete_current_task()
		else:
			error_counter += 1
			task_failed.emit(current_task["id"])
			start_random_task()
	else:
		if signal_minigame.mini_game_completed.is_connected(_on_signal_minigame_completed):
			signal_minigame.mini_game_completed.disconnect(_on_signal_minigame_completed)


# ----------------------- Si la tache est fini à temps ----------------------- #

func complete_current_task():
	if current_task:
		task_timer.stop()
		last_completed_task_id = current_task["id"]
		Global.score += 1
		Global.lightState ="Valid"
		task_completed.emit(current_task["id"])
		start_random_task()

# ----------------------- Si la tache n'est pas fini à temps ----------------------- #

func _on_task_timeout():
	shake_screen(3, 0.8)
	error_counter +=1
	task_failed.emit(current_task["id"])
	if error_counter <= 3:
		start_random_task() 
	else:
		return

# ----------------------- Transition vers l'écran de défaite ----------------------- #

func change_scene_on_failure():
	get_tree().change_scene_to_file("res://Scenes/Lose.tscn")

# ----------------------- Récupérer le compte d'erreur et de score ----------------------- #

func get_completed_tasks_count() -> int:
	return Global.score

func get_failed_tasks_count() -> int:
	return error_counter
