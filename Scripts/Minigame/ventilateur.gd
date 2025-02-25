extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var button = $InteractionVentilateur

func _ready():
	button.pressed.connect(_on_button_pressed)
	update_animation()

func _on_button_pressed():
	if Global.ventilateur == "on":
		Global.ventilateur = "off"
	else:
		Global.ventilateur = "on"
	update_animation()

func update_animation():
	if Global.ventilateur == "on":
		sprite.play()
	else:
		sprite.stop()
