extends Node2D
 
@export var amplitude: float = 25.0 
@export var frequency: float = 1.0 
@export var speed: float = 8.0  
@export var points_count: int = 500
 
signal mini_game_completed(success: bool)
signal signal_selected(signal_name: String)
 
var time: float = 0.0
var current_signal = ""
@onready var line: Line2D = $Line2D
@onready var changeCurveButton = $ChangeCurve
@onready var changeColorButton = $ChangeColor
 
enum CurveType { SIN, M, SQUARE }
var current_curve: int = CurveType.SIN
var current_color: Color = Color(1, 1, 0)
 
var validation_timer: Timer
var is_signal_correct = false
var validation_duration = 0.5
 
func _ready():
	changeCurveButton.pressed.connect(_on_curve_button_pressed)
	changeColorButton.pressed.connect(_on_color_button_pressed)
 
	var main_game = get_node("/root/Panel/TaskManager")
	if main_game.signal_minigame_selected.is_connected(randomize_signal):
		main_game.signal_minigame_selected.disconnect(randomize_signal)
	main_game.signal_minigame_selected.connect(randomize_signal)
	validation_timer = Timer.new()
	validation_timer.wait_time = validation_duration
	validation_timer.one_shot = true
	validation_timer.timeout.connect(_on_validation_timer_timeout)
	add_child(validation_timer)
 
func _process(delta):
	time += delta * speed
	var new_points = []
	for i in range(points_count):
		var t = float(i) / float(points_count - 1)
		var x = t * 400.0
		var y = 0.0
		match current_curve:
			CurveType.SIN:
				y = amplitude * sin(frequency * x * 0.05 + time)
			CurveType.M:
				var wave = sin(frequency * x * 0.05 + time)
				y = amplitude * (3 * wave - 2 * wave * wave * wave)  
			CurveType.SQUARE:
				y = amplitude * (1 if sin(frequency * x * 0.05 + time) > 0 else -1)
		new_points.append(Vector2(x, y))
	line.points = new_points
	line.default_color = current_color
 
func randomize_signal():
	print("Fonction randomize_signal appelée")
 
	var signal_options = ["Mars", "Lune", "Brésil", "Alpha", "Tango", "Quebec"]
	var selected_signal = signal_options[randi() % signal_options.size()]
 
	while selected_signal == current_signal:
		selected_signal = signal_options[randi() % signal_options.size()]
 
	emit_signal("signal_selected", selected_signal)
	current_signal = selected_signal
	is_signal_correct = false
	validation_timer.stop()
 
func _on_curve_button_pressed():
	$ChangeCurve.current_icon_index = ($ChangeCurve.current_icon_index + 1) % $ChangeCurve.position_icons.size()
	$ChangeCurve.icon = $ChangeCurve.position_icons[$ChangeCurve.current_icon_index]
	current_curve = (current_curve + 1) % CurveType.size()
	check_curve_and_color()
 
func _on_color_button_pressed():
	$ChangeColor.current_icon_index = ($ChangeColor.current_icon_index + 1) % $ChangeColor.position_icons.size()
	$ChangeColor.icon = $ChangeColor.position_icons[$ChangeColor.current_icon_index]
	if current_color == Color(1,1,0):
		current_color = Color(0, 1, 1)  # Bleu
	elif current_color == Color(0, 1, 1) :
		current_color = Color(0, 1, 0)  # Vert
	else:
		current_color = Color(1, 1, 0) # Jaune
 
	check_curve_and_color()  
 
func check_curve_and_color():
	var is_correct = false
	if current_signal == "Mars" and current_color == Color(0, 1, 0) and current_curve == CurveType.SIN:
		is_correct = true
	elif current_signal == "Lune" and current_color == Color(1, 1, 0) and current_curve == CurveType.SQUARE:
		is_correct = true
	elif current_signal == "Brésil" and current_color == Color(0, 1, 1) and current_curve == CurveType.M:
		is_correct = true
	elif current_signal == "Alpha" and current_color == Color(0, 1, 0) and current_curve == CurveType.SQUARE:
		is_correct = true
	elif current_signal == "Tango" and current_color == Color(1, 1, 0) and current_curve == CurveType.M:
		is_correct = true
	elif current_signal == "Quebec" and current_color == Color(0, 1, 1) and current_curve == CurveType.SIN:
		is_correct = true
	if is_correct and !is_signal_correct:
		is_signal_correct = true
		validation_timer.start()
		print("Timer de validation démarré: ", validation_duration, " secondes")
	elif !is_correct and is_signal_correct:
		is_signal_correct = false
		validation_timer.stop()
		print("Timer de validation arrêté")
 
func _on_validation_timer_timeout():
	if is_signal_correct:
		print("Signal maintenu pendant ", validation_duration, " secondes - Validation réussie!")
		emit_signal("mini_game_completed", true)
 
func reset_game():
	current_curve = CurveType.SIN
	current_color = Color(1, 1, 0)
	is_signal_correct = false
	validation_timer.stop()