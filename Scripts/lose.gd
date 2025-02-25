extends Node2D

var score = 0
@onready var score_label = $ScoreLabel
@onready var explosion = $Explosion
@onready var exit_button = $ExitButton


func _ready():
	update_score()
	exit_button.pressed.connect(_on_exit_button_pressed)

func update_score():
	score_label.text = "Score: " + str(Global.score)

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
