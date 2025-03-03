extends Node2D

signal mini_game_completed(success: bool)

@onready var indicateur = $Indicateur
@onready var bouton_right = $RotateRight
@onready var bouton_left = $RotateLeft

var target_rotation = 0.0  
var tween: Tween  


func _ready():
	var main_game = null  
	match Global.player_number:
		1:
			main_game = get_node_or_null("/root/Panel/TaskManager")
		2:
			main_game = get_node_or_null("/root/Panel/TaskManagerTwo")
	if main_game:
		main_game.rotation_minigame_selected.connect(randomize_rotation)

	bouton_right.multitouch_pressed.connect(_on_rotate_right)
	bouton_left.multitouch_pressed.connect(_on_rotate_left)


func randomize_rotation():
	var angle
	if randi() % 2 == 0:
		angle = randf_range(-35, -25)  
	else:
		angle = randf_range(25, 35)    
	
	indicateur.rotation = deg_to_rad(angle)
	target_rotation = indicateur.rotation


func _on_rotate_right():
	rotate_indicator(10)

func _on_rotate_left():
	rotate_indicator(-10)

func rotate_indicator(amount):
	target_rotation += deg_to_rad(amount)
	target_rotation = clamp(target_rotation, deg_to_rad(-35), deg_to_rad(35))
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(indicateur, "rotation", target_rotation, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.finished.connect(check_centered)

func check_centered():
	if abs(rad_to_deg(indicateur.rotation)) < 5:
		print("object centré, le signal est censé être envoyé")
		emit_signal("mini_game_completed", true)
