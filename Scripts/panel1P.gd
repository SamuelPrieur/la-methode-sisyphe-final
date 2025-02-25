extends Node2D

# Label
@onready var score_label = $ScoreLabel
@onready var error_label = $ErrorCounter
@onready var minutes_label = $MinutesLabel 
@onready var seconds_label = $SecondsLabel  
@onready var timer = $Timer

#Fondu au noir
@onready var fade_rect = $FadeRect

# Croix erreur
@onready var croix1 = $ErrorCounter/Croix1
@onready var croix2 = $ErrorCounter/Croix2
@onready var croix3 = $ErrorCounter/Croix3
var error_audio1
var error_audio2

# Alert Asset et Light
@onready var alert_light = $AlertLight
@onready var alert = $Alert
var blink_time = 0.0
var blink_speed = 2.0  
var blink_intensity = 0.6 

# Café Asset,Light et Timer
@onready var animation_player = $CafeAnimation
@onready var animated_sprite = $CafeAnimation/Cafe
@onready var random_anim_timer = Timer.new()
var animation_played = false

# Animation de Défaite
@onready var explosion = $Explosion

# Audio
var audio_player_validate
var audio_player_error
var audio_player_lose

# Fichiers Audio
var audio_files = [
	"res://Assets/Audio/Event/DeathCrash1.wav",
	"res://Assets/Audio/Event/DeathCrash3.wav"
]

func _ready():
	# ----------------------- Préparation de l'audio ----------------------- #
	audio_player_lose = AudioStreamPlayer.new()
	add_child(audio_player_lose)

	# ----------------------- Sélection un fichier aléatoire ----------------------- #
	var random_audio = audio_files[randi() % audio_files.size()]
	audio_player_lose.stream = load(random_audio)
	audio_player_lose.volume_db = -15

	# ----------------------- Opacité de chaque croix ----------------------- #
	croix1.modulate.a = 0
	croix2.modulate.a = 0
	croix3.modulate.a = 0
	
	# ----------------------- Liaison avec le TaskManager ----------------------- #
	var task_manager = $TaskManager
	task_manager.task_completed.connect(_on_task_completed)
	task_manager.task_failed.connect(_on_task_failed)
	
	# ----------------------- Animations et Audio ----------------------- #
	timer.start()  
	fade_rect.modulate.a = 1
	animate_fade_in()
	timer.timeout.connect(_on_timer_finished)
	
	add_child(random_anim_timer)
	random_anim_timer.one_shot = true
	random_anim_timer.timeout.connect(_on_random_anim_timer_timeout)
	
	start_random_animation_timer()
	
	audio_player_validate = AudioStreamPlayer.new()
	audio_player_error = AudioStreamPlayer.new()
	add_child(audio_player_validate)
	add_child(audio_player_error)
	audio_player_validate.stream = load("res://Assets/Audio/Event/Validate.wav")
	
	error_audio1 = load("res://Assets/Audio/Event/DamageCrash1.wav")
	error_audio2 = load("res://Assets/Audio/Event/DamageCrash2.wav")
	
	audio_player_validate.volume_db = -15
	audio_player_error.volume_db = -15
	
# ----------------------- Animation du café ----------------------- #
func start_random_animation_timer():
	var random_time = randf_range(1, 5)
	random_anim_timer.start(random_time)

func _on_random_anim_timer_timeout():
	if not animation_played:
		play_animations()
		animation_played = true

func play_animations():
	if animation_player and animated_sprite:
		animation_player.play("new_animation") 
		animated_sprite.play() 

# ----------------------- Animation de l'alarme ----------------------- #

func _process(delta):
	var time_left = int(timer.time_left)
	var minutes = time_left / 60
	var seconds = time_left % 60
	
	# Mise à jour des labels pour les minutes et secondes
	minutes_label.text = "%02d" % minutes
	seconds_label.text = "%02d" % seconds
	
	blink_time += delta
	match Global.lightState:
		"Hold":
			alert.texture = load("res://Assets/Light/LightHold.png")
			alert_light.modulate = Color(0,0,0)
		"Error":
			alert.texture = load("res://Assets/Light/LightError.png")
			var intensity = (sin(blink_time * blink_speed) + 1) / 2 * blink_intensity
			alert_light.modulate = Color(1, 0, 0, intensity)
		"Valid":
			alert.texture = load("res://Assets/Light/LightValid.png")
			var intensity = (sin(blink_time * blink_speed) + 1) / 2 * blink_intensity
			alert_light.modulate = Color(0, 1, 0, intensity)

# ----------------------- Alarme : Réussite ----------------------- #

func _on_task_completed(_task_id: String):
	score_label.text = str(Global.score)
	audio_player_validate.play()
	
# ----------------------- Alarme : Raté ----------------------- #
	
func _on_task_failed(_task_id: String):
	audio_player_error.stream = error_audio1 if randi() % 2 == 0 else error_audio2

	var task_manager = $TaskManager
	var error_count = task_manager.get_failed_tasks_count()

	croix1.modulate.a = 0
	croix2.modulate.a = 0
	croix3.modulate.a = 0
	
	if error_count >= 1:
		croix1.modulate.a = 1
		audio_player_error.play()
	if error_count >= 2:
		croix2.modulate.a = 1
		audio_player_error.play()
	if error_count >= 3:
		croix3.modulate.a = 1
		audio_player_error.play()
	if error_count >= 4:
		audio_player_lose.play()
		explosion.play("Explosion") 
		explosion.animation_finished.connect(_on_explosion_animation_finished)

# ----------------------- Fondu : Animation ----------------------- #

func animate_fade_out():
	if fade_rect:
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 2, 1.5)  
		tween.finished.connect(change_level)
	else:
		print("Erreur : FadeRect n'est pas défini ou introuvable.")

# ----------------------- Fondu : Réussite ----------------------- #

func _on_timer_finished():
	animate_fade_out()

# ----------------------- Fondu : Raté ----------------------- #

func _on_explosion_animation_finished():
	animate_fade_out()

# ----------------------- Fondu : Début ----------------------- #

func animate_fade_in():
	if fade_rect:
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0, 1.5) 
	else:
		print("Erreur : FadeRect n'est pas défini ou introuvable.")

# ----------------------- Changement de Niveau ----------------------- #

func change_level():
	Global.level += 1
	var task_manager = $TaskManager
	var error_count = task_manager.get_failed_tasks_count()
	if error_count > 3:
		get_tree().change_scene_to_file("res://Scenes/Lose.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/LevelTransition.tscn")
