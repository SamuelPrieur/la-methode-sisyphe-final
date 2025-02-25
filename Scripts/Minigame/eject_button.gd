extends Node2D

var first_click_done = false

@onready var fond_sprite = $Fond
@export var second_texture: Texture2D

func _ready():
	# Connecter le signal pressed du bouton à notre fonction
	$EjectButton.pressed.connect(_on_eject_button_pressed)

# Fonction appelée lorsque le bouton est pressé
func _on_eject_button_pressed():
	if not first_click_done:
		# Premier clic: changer le sprite
		if second_texture:
			fond_sprite.texture = second_texture
		else:
			print("ATTENTION: second_texture n'est pas défini dans l'inspecteur")
		
		first_click_done = true
	else:
		get_tree().change_scene_to_file("res://Scenes/Lose.tscn")
