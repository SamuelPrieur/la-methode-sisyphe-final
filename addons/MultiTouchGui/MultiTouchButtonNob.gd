extends Button
class_name MultiTouchButtonNob

@export var icon_position1: Texture
@export var icon_position2: Texture
@export var icon_position3: Texture

var position_icons = []
var current_icon_index = 0

func _ready():
	position_icons = [icon_position1, icon_position2, icon_position3]
	if position_icons[0] != null:
		icon = position_icons[current_icon_index]

#func _gui_input(event):
	#if event is InputEventScreenTouch and event.pressed:
		#if not toggle_mode:
			#current_icon_index = (current_icon_index + 1) % position_icons.size()
			#icon = position_icons[current_icon_index]
			#print("test")
			#toggled.emit()
			#button_pressed = true