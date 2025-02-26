extends Button
class_name MultiTouchButton
 
@export var icon_normal: Texture
@export var icon_pressed: Texture
 
func _ready():
	if icon_normal and not icon:
		icon = icon_normal
 
func _gui_input(event):

	if event is InputEventScreenTouch and event.pressed:
		if toggle_mode:
			toggled.emit()
			button_pressed = true
		else:
			pressed.emit()
			button_down.emit()
			icon = icon_pressed

	elif event is InputEventScreenTouch or (event is InputEventScreenTouch and !event.pressed):
		button_up.emit()
		icon = icon_normal
		button_pressed = false

