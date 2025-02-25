extends Node2D

# Récupérer le code généré aléatoire
signal keypad_code_generated(code: String)

# Label
@onready var code_label = $Code
# Code actuel
var current_code = ""
#Code à valider
var target_code = ""
const MAX_CODE_LENGTH = 4

func _ready():
	code_label.text = ""
	$KeyPad1.pressed.connect(func(): _on_key_pad_pressed(1))
	$KeyPad2.pressed.connect(func(): _on_key_pad_pressed(2))
	$KeyPad3.pressed.connect(func(): _on_key_pad_pressed(3))
	$KeyPad4.pressed.connect(func(): _on_key_pad_pressed(4))
	$KeyPad5.pressed.connect(func(): _on_key_pad_pressed(5))
	$KeyPad6.pressed.connect(func(): _on_key_pad_pressed(6))
	$KeyPad7.pressed.connect(func(): _on_key_pad_pressed(7))
	$KeyPad8.pressed.connect(func(): _on_key_pad_pressed(8))
	$KeyPad9.pressed.connect(func(): _on_key_pad_pressed(9))
	
	$KeyPadErase.pressed.connect(_on_key_pad_erase_pressed)
	$KeyPadEnter.pressed.connect(_on_key_pad_enter_pressed)

	print(keypad_code_generated)

# ----------------------- Gestion : Bouton Chiffre ----------------------- #

func _on_key_pad_pressed(number):
	if current_code.length() < MAX_CODE_LENGTH:
		current_code += str(number)
		update_code_display()

# ----------------------- Gestion : Bouton Supprimer ----------------------- #

func _on_key_pad_erase_pressed():
	if not current_code.is_empty():
		current_code = current_code.substr(0, current_code.length() - 1)
		update_code_display()

# ----------------------- Gestion : Bouton Valider ----------------------- #

func _on_key_pad_enter_pressed():
	if current_code.length() == MAX_CODE_LENGTH:
		check_code()

# ----------------------- Afficher le code actuel ----------------------- #

func update_code_display():
	code_label.text = current_code

# ----------------------- Récupérer le code généré ----------------------- #

func _on_keypad_code_generated(code: String):
	target_code = code
	
	

# ----------------------- Comparer le code tapé et le code correct ----------------------- #

func check_code():
	if current_code == target_code:
		get_parent().complete_current_task() 
	
	current_code = ""
	update_code_display()
